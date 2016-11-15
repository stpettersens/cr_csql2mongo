@rem Run compiled Crystal program on local linux server.
@echo %2 %3 %4 %5 %6 > prog.sh 
@pscp -pw %1 prog.sh compiler@192.168.0.18:job
@plink -ssh compiler@192.168.0.18 -pw %1 -m runner.txt -t
