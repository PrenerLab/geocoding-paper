# Generate Addresses.txt

data <- read.csv('data/STL_CRIME_Homicides.csv', stringsAsFactors = FALSE)['address_norm']
data <- simplify2array(data)
data <- paste0(data, ' St. Louis, MO')

# Problem Sending Empty Newlines...

write.table(data, 'data/addresses.txt', row.names = FALSE, col.names = FALSE, quote = FALSE)
