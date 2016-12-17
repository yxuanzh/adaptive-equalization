function str=vec2str(vec)
str=num2str(vec);
while strfind(str,' ')
    str = strrep(str,' ','');
end