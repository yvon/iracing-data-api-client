reset
set timestamp "%d/%m/%y %H:%M GMT"
set term svg size 1000,500
set view map
set tics nomirror
set border 10
set xrange noextend
set yrange noextend
set xtics 500
set ytics 1 scale 0.4,0.2
set mytics 4
set mxtics 2
set ydata time
set format y "%tM:%tS"
set dgrid3d 20,40 gauss kdensity 400,0.5
set palette defined (0 "white", 1 "#aa88dd")
set output
unset colorbox
splot $Data using 1:($2/10000):(1) with pm3d notitle, \
'' using 1:($2/10000):(1) with points lc "#6a558a" pt 5 ps 0.5 nogrid notitle
