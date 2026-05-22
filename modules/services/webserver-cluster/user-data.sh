#!/bin/bash
# Create both index files
cat > index.html <<EOF
<h1>Hello, World</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF

# Also create index.xhtml (for compatibility)
cp index.html index.xhtml

# Start the web server
nohup busybox httpd -f -p ${server_port} &