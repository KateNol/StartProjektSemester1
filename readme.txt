How to copy branch into main


git checkout master

git checkout branch_from_which_you_have_to_copy_the_files_to_master .

(with period)

git add --all

git push -u origin master

git commit -m "copy from branch to master"