[ -n "$(ls -A output 2>/dev/null)" ] && rm -r output/*
cd input

# Find all .cs files in directory
csfiles=(`find ./ -maxdepth 1 -name "*.cs"`)
configs=(`find ./ -maxdepth 1 -name "*.csproj"`)
slnfiles=(`find ./ -maxdepth 1 -name "*.sln"`)
zipfiles=(`find ./ -maxdepth 1 -name "*.zip"`)

# Check if directory contains .NET project
if [ ${#configs[@]} -gt 0 ] && [ -d "obj" ] && [ ${#csfiles[@]} -gt 0 ]; then
    cp -a /input/. /output/
else
    if [ ${#csfiles[@]} -gt 0 ]; then
        cd ..
        dotnet new console -o output
        rm /output/Program.cs
        cp -a /input/. /output/
    fi
fi

if [ ${#slnfiles[@]} -gt 0 ]; then
    cp -a /input/. /output/
fi

if [ ${#zipfiles[@]} -gt 0 ]; then
    source="./"
    find "$source" -name "*.zip"
    shopt -s dotglob
    for file in "${source}"/*.zip
    do
       if [ -f "${file}" ]; then
          unzip $file
          rm -r $file
       fi
    done
    [ -d "__MACOSX" ] && rm -r __MACOSX
    cp -a /input/. /output/
fi
