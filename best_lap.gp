reset
set title "Meilleur tour en fonction de l'Irating"
set timestamp "%d/%m/%y %H:%M"
set term pngcairo crop size 2000,1000

stats 'data.txt' using 1:2 nooutput
xmin = STATS_min_x
xmax = STATS_max_x
ymin = STATS_min_y
ymax = STATS_max_y
xrange = xmax - xmin
yrange = ymax - ymin
xsize = xrange / 8000
ysize = yrange / 80000
set size xsize, ysize

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
set dgrid3d (yrange/4000),(xrange/200) gauss kdensity 400,0.5
set palette defined (0 "white", 1 "#aa88dd")
unset colorbox
splot 'data.txt' using 1:($2/10000):(1) with pm3d notitle, \
      '' using 1:($2/10000):(1) with points lc "#6a558a" pt 5 ps 0.5 nogrid notitle
