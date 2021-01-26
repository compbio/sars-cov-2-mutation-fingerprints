module sarscov2primers

import ArgParse

const version_info = v"0.1.0"
const prog_string = "primerpairs"
const version_string = "$(prog_string) command line interface $(version_info), by Dmitri Pavlichin"
const description_string = "Generate primer pairs for SARS-CoV-2 genomes"
const default_output_file = "out.csv"
const ref_genome_length = 29891 # SARS-CoV-2 reference genome length
const k = 25 # k-mer k

const arg_parse_settings = ArgParse.ArgParseSettings(
    prog = prog_string,
    description = join((version_string, description_string), "\n", "\n\n\n\n"),
    version = version_string,
)


ArgParse.@add_arg_table! arg_parse_settings begin
    "--coordinates", "-c"
        help = "pair of start and stop coordinates of target in SARS-CoV-2 reference genome"
        nargs = 2
        default = [k, ref_genome_length - k]
        arg_type = Int
    "--max-amplicon-length"
        help = "maximum amplicon length between forward and reverse primers (in the SARS-CoV-2 reference genome; length may be larger in other genomes if there are insertions)"
        default = 2500
        arg_type = Int
    "--min-amplicon-length"
        help = "minimum amplicon length between forward and reverse primers (in the SARS-CoV-2 reference genome; length may be shorter in other genomes if there are deletions)"
        default = 1
        arg_type = Int
    "--max-gc-diff"
        help = "maximum difference in GC content between forward and reverse primers"
        default = 2
        arg_type = Int
    "--output-file", "-o"
        help = "output file"
        default = default_output_file
        arg_type = String
    "--version", "-V"
        help = "display version number and exit"
        action = :show_version
end

# input files
#const sarscov2_4K_genomes_file = "../../genomes/sars-cov-2/sars-cov-2_4K_2020-4-9.fa"
const unique_conserved_kmers_file =          "kmer_counts/unique_conserved_25-mers_sars-cov-2_4K.bed"
const unique_conserved_specific_kmers_file = "kmer_counts/unique_conserved_specific_25-mers_sars-cov-2_4K.bed"
const input_files = (unique_conserved_kmers_file, unique_conserved_specific_kmers_file)

"""Return misisng expected input files, possibly uncompressing them"""
function missingsources()::Vector{String}
    missing_sources = String[]

    for file in input_files
        if !isfile(file)
            if isfile(file*".gz")
                @info "uncompressing $(file)"
                run(pipeline(`gunzip -k $(file)`))
            else
                push!(missing_sources, file)
            end
        end
    end

    return missing_sources
end

"""Reverse complement of DNA string `dna`"""
function rc(dna::AbstractString)
    replace(codeunits(dna), UInt8('A')=>UInt8('T'), UInt8('T')=>UInt8('A'), UInt8('C')=>UInt8('G'), UInt8('G')=>UInt8('C')) |> reverse .|> Char |> join
end

"""Canonical form of DNA string `dna`"""
canonical(dna::AbstractString) = min(dna, rc(dna))

function gccontent(kmer::AbstractString)
    count(x->x∈"CG", kmer)
end

# Return vector of start=>kmer
function primersfrombed(bed_file)::Dict{Int,String}
    @assert isfile(bed_file)
    split_lines = split.(readlines(bed_file), '\t')
    #primers = [(start=parse(Int, s[2]), stop=parse(Int, s[3]), kmer=String(s[4])) for s in split_lines]
    primers = Dict{Int,String}((parse(Int, s[2]) + 1)=>String(s[4]) for s in split_lines)
end

function findleastupperboundinsortedvec(v::DenseVector{T}, x::T) where T<:Real
    # returns index of least upper bound x in v
    # if x is greater than greatest element of v, return length(v)
    # assumes v is sorted in ascending order
    
    lower = firstindex(v)
    upper = lastindex(v)
    while lower < upper
        mid = div(upper+lower,2)
        if x <= v[mid]
            upper = mid
        else
            lower = mid+1
        end
    end
    lower
end

function findgreatestlowerboundinsortedvec(v::DenseVector{T}, x::T) where T<:Real
    # returns index of greatest lower bound x in v
    # if x is greater than greatest element of v, return 1
    # assumes v is sorted in ascending order
    
    lower = firstindex(v)
    upper = lastindex(v)
    while lower < upper
        mid = div(upper+lower,2)+1
        if x < v[mid]
            upper = mid-1
        else
            lower = mid
        end
    end
    lower
end

"""get primer pairs touching any position between `start` and `stop`, max
amplicon length `max_amplicon_length`, max GC content difference
`max_gc_diff`"""
function primerpairs(start::Integer, stop::Integer, max_amplicon_length::Integer, min_amplicon_length::Integer, max_gc_diff::Integer)

    if min_amplicon_length <= 0
        @warn "minimum amplicon length must be positive; using 1 instead"
        min_amplicon_length = 1
    end

    unique_conserved_primers_starts::Vector{Pair{Int,String}} = sort(collect(primersfrombed(unique_conserved_kmers_file)))
    
    starts = [x[1] for x in unique_conserved_primers_starts]
    f_primers = [x[2] for x in unique_conserved_primers_starts]

    unique_conserved_specific_primers_canonical::Set{String} = Set([canonical(kmer) for kmer in values(primersfrombed(unique_conserved_specific_kmers_file))])

    min_start = max(start - k - max_amplicon_length + 1, 0)
    max_stop = min(stop + max_amplicon_length, ref_genome_length)

    start_index = findleastupperboundinsortedvec(starts, min_start)
    stop_index = findgreatestlowerboundinsortedvec(starts, max_stop)

    # TODO: iterate i_right using fact that must start inside target
    primer_pairs = []
    for i_left in start_index:stop_index
        for i_right in (i_left + 1):stop_index
            f_start = starts[i_left]
            r_start = starts[i_right]
            amplicon_length = r_start - f_start - k
            amplicon_length < min_amplicon_length && continue
            amplicon_length > max_amplicon_length && break # sorted

            # check that overlap target
            ((r_start <= start) || (f_start + k - 1 >= stop)) && continue

            f_primer = f_primers[i_left]
            r_primer = f_primers[i_right]
            abs(gccontent(f_primer) - gccontent(r_primer)) > max_gc_diff && continue
            !((canonical(f_primer) ∈ unique_conserved_specific_primers_canonical) || (canonical(r_primer) ∈ unique_conserved_specific_primers_canonical)) && continue

            push!(primer_pairs, (f_start=f_start, r_start=r_start, f_primer=f_primer, r_primer=r_primer))
        end
    end

    return primer_pairs
end

function writeprimerpairs(file::AbstractString, primer_pairs)

    unique_conserved_specific_primers_canonical::Set{String} = Set([canonical(kmer) for kmer in values(primersfrombed(unique_conserved_specific_kmers_file))])

    @info "found $(length(primer_pairs)) primer pairs"
    @info "writing outout to $(file)"

    open(file, "w") do io
        println(io, "forward (5' to 3'),reverse (5' to 3'),forward strand,reverse strand,forward start,forward stop,reverse start,reverse stop,amplicon length,forward GC content (%),reverse GC content (%),forward specific,reverse specific")
        for pp in primer_pairs
            f_primer = pp.f_primer
            r_primer = pp.r_primer
            f_specific = canonical(f_primer) ∈ unique_conserved_specific_primers_canonical
            r_specific = canonical(r_primer) ∈ unique_conserved_specific_primers_canonical
            amplicon_length = pp.r_start - pp.f_start - k
            println(io, join((f_primer, rc(r_primer), '+', '-', pp.f_start, pp.f_start + k - 1, pp.r_start, pp.r_start + k - 1, amplicon_length, gccontent(f_primer), gccontent(r_primer), f_specific, r_specific), ','))
        end
    end
    return
end

function main()
    # check have input files
    for missing_source in missingsources()
        error("missing input file: $(missing_source)")
    end

    parsed_args = ArgParse.parse_args(arg_parse_settings)

    coordinates = parsed_args["coordinates"]
    max_amplicon_length = parsed_args["max-amplicon-length"]
    min_amplicon_length = parsed_args["min-amplicon-length"]
    max_gc_diff = parsed_args["max-gc-diff"]
    #verbose = parsed_args["verbose"]
    output_file = parsed_args["output-file"]

    primer_pairs = primerpairs(coordinates[1], coordinates[2], max_amplicon_length, min_amplicon_length, max_gc_diff)
    writeprimerpairs(output_file, primer_pairs)
end

end # module
