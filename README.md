# basecamp_scripts
Simple command line scripts for basecamp.

# Upload Files From Command Line
Uploads a file to a project from the command line. Automatically detects file size and takes care of upload for you. This could be used in connection with other scripts or by the windows task scheduler.
```
Usage: /upload/basecampupload.rb [options]
 Example I:
         ruby basecampupload.rb
                        -f filename.zip
                        -C 1111111
                        -P 2222222
                        -s '1234, 4321, 1221'
                        -m 'Your Message Here'
                        -a 'email@address.com'
                        -u 'email@address.com'
                        -p 'p@ssword'
 Example II:
         ruby basecampupload.rb
                        -C 1111111
                        -P 2222222
                        -a 'email@address.com'
                        -u 'email@address.com'
                        -p 'p@ssword'
                        -g true 
    -f, --filename filename          Full name and path for the zip.
    -t, --content_type type          The file type being uploaded.
                                     Like:
                                     'application/zip'
    -C, --company #                  Your basecamp company ID
    -P, --project #                  Your basecamp project ID
        --authorization base64encode Basecamp user:pass base64 encode string. Optional authentication methods: username and password or base46 encoded string.
                                     Like:
                                     'Basic base46encode'
    -s, --subscribers #              Subscribers are user id's for those who will be informed that a file has been uploaded.
                                     Like:
                                     '1, 2, 3'
    -m, --message message            Latest zip file.
    -a, --user_agent email           User account used for base64 encode email@company.ext
    -u, --username username          User account. Optional authentication methods: username and password or base46 encode.
    -p, --password password          User password. Optional authentication methods: username and password or base46 encode.
    -g, --get_users true             Bypass file upload and displays users for a project in json output.
                                     This is useful if you don't yet know what the subscriber id's are and want to print out that information.
    -d, --debug true                 Prints values set.
    -h, --help                       Displays Help
```
