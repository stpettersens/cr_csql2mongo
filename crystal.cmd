@rem Compile with Crystal compiler running on local linux server.
@echo crystal %2 -o %3 > compile.sh 
@pscp -pw %1 -r src compile.sh %4 compiler@192.168.0.18:job
@plink -ssh compiler@192.168.0.18 -pw %1 -m compiler.txt -t
