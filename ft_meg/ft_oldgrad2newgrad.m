function sens = ft_oldgrad2newgrad(grad)
    % converts the older sensor definition to a newer one for Fieldtrip
    sens.label      = grad.label;
    sens.chanpos    = grad.pnt;
    sens.chanori    = grad.ori;
    sens.tra        = grad.tra;
    sens.balance    = grad.balance;
    sens.unit       = grad.unit;
end