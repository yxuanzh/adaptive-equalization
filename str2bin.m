function bin=str2bin(str)
bin=[];
   for i=0:length(str)-1
       if str(i+1)==' '
           bin=[bin,'00000'];
       else
           ascii=abs(str(i+1));
           bin=[bin,dec2bin(ascii-96,5)];
       end
   end
   for t=1:length(bin)
     bin_convert(t)=str2num(bin(t));
   end
   bin=bin_convert;
end