@rem Run compiled crystal program on local linux server.
@echo %2 %3 > prog.sh 
@pscp -pw %1 prog.sh sam@192.168.0.18:job
@plink -ssh sam@192.168.0.18 -pw %1 -m runner.txt -t
