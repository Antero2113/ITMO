#!/bin/bash
mkdir -p $HOME/zfb92/log
cat > $HOME/zfb92/pg_hba.conf << 'EOF'
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   loudwhiteuser   testuser                               peer map=peermap
local   all             all                                     peer
host    all             all             127.0.0.1/32            ident
host    all             all             ::1/128                 ident
host    all             all             0.0.0.0/0               reject
host    all             all             ::/0                    reject
EOF

cat >> $HOME/zfb92/pg_ident.conf << 'EOF'
# Системный пользователь postgres2 может подключаться как testuser
peermap    postgres2    testuser
EOF

