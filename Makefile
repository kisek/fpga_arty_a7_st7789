all:
	verilator --binary main.v top.v -top top
	gcc -O2 dispemu.c -o dispemu -lcairo -lX11

run:
	obj_dir/Vtop | dispemu 2


clean:
	rm -r -f dispemu obj_dir
