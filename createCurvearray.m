function [curvearray] = createCurvearray(y_start_p,y_end_p,approximation,fitmethod,fitresult)
clear curvearray;
curvearray=zeros((y_end_p-y_start_p),1);
z=1;
if (fitmethod==1)
    for i=y_start_p:y_end_p
        curvearray(z)=approximation(1)*i^9 + approximation(2)*i^8 + approximation(3)*i^7+ approximation(4)*i^6 + approximation(5)*i^5 + approximation(6)*i^4  + approximation(7)*i^3 + approximation(8)*i^2 + approximation(9)*i + approximation(10);
        %  a=approximation(1);
        % b=approximation(2);
        % c=approximation(3);
        % %curvearray(i)=10^(log10((i+c)/a)/b)
        % curvearray(z)=a*(i^b)+c;
        z=z+1;
    end
elseif(fitmethod== 2)
    curvearray=fitresult((y_start_p:y_end_p));
end

end
%grid on

