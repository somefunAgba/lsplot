# LSP: Live Serial Plot
## **Visualize real-time logged data from Arduino in MATLAB®.**
### `2021-08-18` | **v1.0** | **Oluwasegun Somefun, oasomefun.futa.edu.ng**
# **Usage Demo:**

A typical use-case involves writing the **three lines of code below in order**.

```matlab:Code
%% - initialize
viz = lsp; % default
% purpose: to setup the port or baudrate: 
% viz = lsp(port,baudrate);
% e.g: on windows: 
% viz = lsp("COM3",9600);

%% - set clock
viz.setclk(); % default
% purpose: to setup the sample time or total samples 
% to log before session ends
% viz.setclk(sampleTime, frameLength);
% e.g:
% viz.setclk(1,5000);

%% - view the stream
viz.render();

%% (optional) -save
sd = viz.sd;
save('sdlog.mat', sd);

```

# What it does:

   -  **Streams** communicated data from serial stored sample by sample in a numeric array `sd.`  
   -  **Plots** the contents of `sd` in real-time. 
   -  **Access** full logged data at the end of the logging session for later preprocessing and analysis 
   -  **Customize** visualization as it fits your purpose using a `render` method. 

# Motivation:

I wrote up this package due to my frustration with available scripts and tools for quick visualizing of the streams of logged signals from the Arduino Development Board in the Matlab IDE.

I wanted it to be minimalistic, and to a large extent generalise to the amount of logged data size

This package does **real time logging and visualization** of Arduino signals in Matlab.

# FAQS:

**Q1. What format should I use to log my Serial Output from Arduino to Matlab?**

**A1.**

In the ***`.[ino, c, cpp]`** source file that you will upload to the Arduino Board, 

you should write up a valid **`C-`****like** syntax (without the `%` **comment** symbol) like this:

`For N = 1 variable`

```matlab:Code
% // debug: to serial monitor
% Serial.println((String) var_1);
```

`For N > 1 variables, use commas to separate the variables. `

`e.g: for N = 4 variables`

```matlab:Code
% // debug: to serial monitor
% Serial.println( (String) var_1 + "," + var_2 + "," + var_3 + "," + var_4);
```

**Note**: To ensure **data integrity **and any other related problem. Ensure there is only one `Serial.println` command in the source file uploaded to the Arduino Board.

  

**Q2. How do I access the full logged data at the end of the logging session?**

**A2.**

For later preprocessing and analysis, you can **access** and **save** the complete streamed data from the MATLAB workspace. To achieve this, you would do something like this:

```matlab:Code(Display)
% -save
sd = lsp.sd;
save('datalog.mat', sd);
% -later access
logdata = load('datalog.mat');
view(logdata.sd); 
```

  

**Q3.** **I want to customize the plots**

**A3.**

In this package, plotting is done with the **`render`** method. The, current default style is to tile the plots of all the signals being logged so the user can view them in different cells of one figure canvas. 

This should work well for most quick prototypings and visualizations. It seems impossible, with the use of a single function to meet the needs of everyone using this package.

However, you might for reasons best known to you, want to customise the plotting configuration, especially if you know your way around plotting tools in Matlab. 

To do this you will need to edit the **`render`** `method` in the **`lsp`** `class`, so it can work according to your needs.

  

**Q4. Arduino board is not detected or any other serial port related problems.**

**A4**.

Ensure, your board is properly configured for use in Matlab. One way is to ensure your Matlab installation has the **MATLAB® Support Package for Arduino® Hardware** which enables MATLAB to interactively communicate with an Arduino board.

Also during runs, ensure no other resource is using Arduino's serial port such as the Arduino IDE or any other tool.

**Q5. This FAQ doesn't cover my question!**

**A5.**

Open an **Issue** on Github.

# How to download and install
## Recommended Approach(es) 

Clone this GitHub repository and open it in MATLAB.

```matlab:Code
% Execute in MATLAB:
system("git clone https://github.com/somefunagba/lsplot");
cd lsplot  
install;
```

## Other(s)

   -  Download **LSP.mltbx **from Matlab's **FileExchange**  
   -  Use the **Add-Ons Explorer** in MATLAB to find and install **LSP**.
