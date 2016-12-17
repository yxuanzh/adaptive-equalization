function str=bin2str(bin)
      str=[];
      len=length(bin);
      for i=0:((len/5)-1)
          symbol=vec2str(bin((i*5+1):(i*5+5)));
          if symbol=='00000'
              str=[str,' '];
          else
              ascii=bin2dec(symbol)+96;
              charac=char(ascii);
              str=[str,charac];
          end
          
      end




end