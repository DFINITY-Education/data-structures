
# Part A
1.  Go to https://github.com/dfinity/vessel
2. Click on "Releases" on the right hand side.
3. Download the version appropriate for your operating system.

# Part B
4. Once the file is in your directory, you want to put the file into your path.
5. To do so, open your terminal and type: *echo $PATH*. 
6. From there, depending on the file you downloaded and where it was saved locally, you want to move that file. 
Something like so: *mv Downloads/vessel-macos /usr/local/bin/vessel*
8. Note, if "permission is denied", execute the following command: *sudo mv Downloads/vessel-macos /usr/local/bin/vessel*
9. Make vessel and executable by the following command: *chmod +x /usr/local/bin/vessel*
