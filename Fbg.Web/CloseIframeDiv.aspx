﻿<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CloseIframeDiv.aspx.cs" Inherits="CloseIframeDiv" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
      
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js" type="text/javascript"></script>

    <script type="text/javascript">
         $(window).load(
        function () {
            parent.$('#imgIframeClose').click();
        }
    )
     </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>
