%build a string that will have leading 0s based on val
function prefix = funcBuildZPrefix(val)
    prefix = num2str(val);
    if(val<1000)
        prefix = strcat('0',prefix);   
        if(val<100)
            prefix = strcat('0',prefix);   
            if(val<10)
                prefix = strcat('0',prefix);
            end
        end
    end
end