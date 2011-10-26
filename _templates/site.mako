<%inherit file="base.mako" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
    ${self.head()}
</head>
<body>
    <div id="container">
        <div id="header"> 
        ${self.header()}
        </div>
	    ${next.body()}
	    <div class="break" />
	</div>
    ${self.footer()}
</body>
</html>


<%def name="head()">
  <%include file="head.mako" />
</%def>
<%def name="header()">
  <%include file="header.mako" />
</%def>
<%def name="footer()">
  <%include file="footer.mako" />
</%def>
