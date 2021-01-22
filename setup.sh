# download Julia 1.5.3
JULIA_VERSION=1.5.3
echo "## downloading Julia $JULIA_VERSION..."
curl -OJ "https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.3-linux-x86_64.tar.gz"

echo "## unpacking Julia..."
tar -xzf julia-1.5.3-linux-x86_64.tar.gz

echo "## setting up scripts..."
export JULIA_DEPOT_PATH=$PWD/julia-1.5.3/depot
./julia-1.5.3/bin/julia -e '@show DEPOT_PATH; import Pkg; Pkg.add(path="."); using sarscov2primers;'

echo "## cleaning up..."
rm julia-1.5.3-linux-x86_64.tar.gz