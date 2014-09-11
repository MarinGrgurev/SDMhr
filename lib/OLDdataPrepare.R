length(split(dataw,dataw[c(2,3)],drop=TRUE))

# Split df prema 2 različita faktora i daj mi prvi element liste
split(data,data[c(2,3,4)], drop=TRUE)[1]
length(split(data,data[c(2,3,4)], drop=TRUE)[1])

# Split df prema 3 različita faktora i daj mi drugi element liste
split(data,data[c(2,3,4)], drop=TRUE)[2]
length(split(data,data[c(2,3,4)], drop=TRUE)[2])

# Split df prema 2 različita faktora (pres_abs i ecolvar) i daj mi drugi element liste
split(data,data[c(2,4)], drop=TRUE)[2]
length(split(data,data[c(2,4)], drop=TRUE))

# Plotting elements from a list
plot(x[[6]][[3]], x[[6]][[5]])
plot(x[[5]][[3]], x[[5]][[5]])
