for file in compiler-output/*
do
    mv "${file}" input/output
done

chmod +x input/output
mv checker input/checker

cd input
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
./checker

cd ..
rm -rf output/*
mv input/out.json output/out.json