% check whether we are getting the eye signal or not
if ~ML_eyepresent, error('This task requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);'); % hotkey to stop the task
% bhv_variable('trialSequenceRand', trialSequenceRand);
set_bgcolor([0.5 0.5 0.5]); % for grey subject screen

% Check for the protocol to run
switch MLConfig.ExperimentName(1)
    case 'M'
        if MLConfig.ExperimentName(2) == '2'
            runGamma = 1;
        else
            runGamma = 0;
        end
    case 'G'
        runGamma = 1;
    case 'E'
        runGamma = 0;       
end

% Define variables
fixation_point = 1;
gratingSfOri = 2; %1
fixation_duration = 1250;
stimulus_duration = 1250; %defining time intervals (ms)

% Get Trial Details
x = TrialRecord.CurrentCondition+20;
y = TrialRecord.CurrentCondition+40;

% initial fixation:
toggleobject(fixation_point,'eventmarker',250);
idle(fixation_duration);
%Stimuli
if runGamma
    toggleobject(gratingSfOri, 'eventmarker',x);
    idle(stimulus_duration);
    toggleobject(gratingSfOri, 'eventmarker',y);
else
    toggleobject(fixation_point,'status','on','eventmarker',251);
    idle(stimulus_duration);
end
trialerror(0); % correct trial
set_iti(100);