classdef lsp < handle
    %LSP : Live Serial Plot
    %      Plots serial data expected from an Arduino dev. board
    %2021-08-18 | v1.0 | Oluwasegun Somefun, oasomefun.futa.edu.ng
    %
    properties
        % Port name to which the Arduino or MCU Board is Connected e.g COM4
        thisPort = serialportlist;
        % * Safe baud rate
        thisBaudRate = 9600;
        % final time of plot view simulation
        discreteTimes = inf;
        % sampling time
        samplingTime = 1e-2;
        % terminator
        eofTerminator = "CR/LF";
        % place holder for this serial port
        boardconn;
        row_dim;
        col_dim;
        % serial data stream from board
        sd;
        
        % place holders for viewing data
        datastr = "";
        datanum = 0;
        
        dplot = 0;
        dtime = 0;
        t;
        
        % Figure
        lspfig;
        lspax;
        
    end
    
    methods
        function obj = lsp(port,baudrate)
            %LSP Construct an instance of this class
            %    instance to enable this lsp (live serial plot)
            arguments
                port string {mustBeNonempty, mustBeText, mustBeTextScalar} = serialportlist("available")
                baudrate (1,1) double {mustBeNonempty, mustBeNumeric, mustBeScalarOrEmpty} = 9600
            end
            
            % check if port exists in serialportlist
            % check if serialportlist is empty.
            
            obj.thisPort = port;
            % * Safe baud rate
            obj.thisBaudRate = baudrate;
            
            if ismac || isunix
                obj.eofTerminator = "LF";
            elseif ispc
                obj.eofTerminator = "CR/LF";
            else
                obj.eofTerminator = "CR";
            end
            
            % Assuming serial port is not in use
            % Set serial port connection to board
            obj.boardconn = serialport(obj.thisPort,obj.thisBaudRate,...
                'FlowControl', 'hardware');
            configureTerminator(obj.boardconn,obj.eofTerminator);
            
            
            
            % Read Data communicated from serial port
            % assumes it is a comma separated list or string.
            obj.boardconn.Timeout = 30;
            obj.datastr = readline(obj.boardconn);
            if ~isempty(obj.datastr)
                obj.datastr = regexp(obj.datastr, '\,*', 'split');
                % convert to numeric array
                obj.datanum = str2double(obj.datastr);
                [obj.row_dim, obj.col_dim] = size(obj.datanum);
                
                % reset place holders for the data
                obj.datastr = "";
                obj.datanum = 0;
                
                obj.sd = zeros(obj.row_dim,obj.col_dim);
                obj.dplot = 0;
                obj.dtime = 0;
            else
                disp('No serial data detected');
            end
            
            
        end
        
        function obj = setclk(obj,tsample,tcounts)
            %SETCLK Set timing for plot
            %   Configures the timing delay between successive values
            %   received from the serial port
            arguments
                obj
                tsample (1,1) {mustBeNonempty,mustBeNumeric, mustBeFinite}
                tcounts (1,1) {mustBeNonempty,mustBeNumeric} = inf
            end
            %
            obj.samplingTime = tsample;
            % total times to log data excluding initial polling
            obj.discreteTimes = tcounts;
            if isfinite(obj.discreteTimes)
                obj.t = zeros(obj.discreteTimes+1,1);
            else
                obj.t = zeros(1000,1);
            end
            
        end
                
        function obj = render(obj)
            
            % start time in loop
            % Sample Evolution (Discrete Timing)
            id = 1;
            % Prepare Figure Canvas
            obj.lspfig = figure;
            obj.lspax = tiledlayout(obj.lspfig,'flow');
            
            while (true)
                %  try
                %countsid(id,1) = id; % store sample count
                disp(id);
                
                % Read Data communicated from serial port
                obj.datastr = readline(obj.boardconn);
                
                if ~isfinite(obj.discreteTimes) && isempty(obj.datastr)
                    % free up port for re-use
                    obj.clear;
                    break;
                end
                if isfinite(obj.discreteTimes) && isempty(obj.datastr)
                    % free up port for re-use
                    obj.clear;
                    break;
                end
                
                if isfinite(obj.discreteTimes)
                    if id > obj.discreteTimes + 1
                        % free up port for re-use
                        obj.clear;
                        break;
                    end
                else % if isinfinite
                    if id > obj.discreteTimes
                        extra = 1000;
                        prev_timedims = size(obj.t);
                        new_timedims = prev_timedims + extra;
                        obj.discreteTimes = new_timedims;
                        new_t = zeros(new_timedims,1);
                        new_t(1:prev_timedims,1) = obj.t;
                        obj.t = new_t;
                    end
                    
                end
                obj.t(id+1) = obj.t(id) + obj.samplingTime;

                % Split comma separated string of polled data 
                % space -> \s* , comma -> \,
                % -string data
                obj.datastr = regexp(obj.datastr, '\,*', 'split');
                % -numeric data
                obj.datanum = str2double(obj.datastr);
                %assert(size(obj.datanum), [obj.row_dim, obj.col_dim]);
                % row_dim == 1, idr = 1
                % -streamed numeric data
                for idc = 1:obj.col_dim
                    obj.sd(id,idc) = obj.datanum(obj.row_dim,idc);
                end
                
                % Place Holder for polled data up to current sample
                obj.dtime = obj.t(1:id);
                obj.dplot = obj.sd(1:id, :);
                
                % Visualizer for streamed data
                vizcolor = lines; % use matlab's color array function
                
                for idc = 1:obj.col_dim
                    nexttile
                    % change stairs to any other plot function
                    %
                    % stairs use -> discrete-time data
                    stairs(obj.dtime,obj.dplot(:,idc),...
                        'Color',vizcolor(idc,:),...
                        'LineWidth',0.5);
                    grid("on");
                    title("signal: "+num2str(id));
                    %hold(obj.lspax, "on");
                end
                % hold(obj.lspax,"off");
                
                drawnow limitrate; % update screen
                
                % update counters
                id = id + 1;
                
            end
            % draw final frame
            drawnow;
            % clear arduino board's serial conn
            obj.clear();
        end
        
        function obj = clear(obj)
            % clear lsp
            delete(obj.boardconn);
            clear obj.boardconn;
        end
        
        
    end
end

