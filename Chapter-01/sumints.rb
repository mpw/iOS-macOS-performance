total=0;
for k in 1..ARGV[0].to_i * 1000
sum=0;
for i in 1..1000
	sum+=i;
end
total+=sum;
end
print sum;
print "\n";
print total;
print "\n";
