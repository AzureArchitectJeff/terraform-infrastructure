#!/bin/bash
cat > index.xhtml <<ENDOFHTML
<h1>Hello, World</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
ENDOFHTML
nohup busybox httpd -f -p ${server_port} &