APP=csql2mongo

make:
	crystal src/$(APP).cr -o $(APP)
clean:
	rm -f $(APP)
