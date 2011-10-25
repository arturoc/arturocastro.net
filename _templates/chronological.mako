<%inherit file="site.mako" />
<div id="col_1">
% for post in posts:
  <%include file="post.mako" args="post=post,resume=True,col2=False" />
<!--
% if bf.config.blog.disqus.enabled:
  <div class="after_post"><a href="${post.permalink}#disqus_thread">Read and Post Comments</a></div>
% endif
  <hr class="interblog" />
  
-->
% endfor
% if prev_link:
 <a class="blog_link" href="${prev_link}">« Previous Page</a>
% endif
% if prev_link and next_link:
  --  
% endif
% if next_link:
 <a class="blog_link" href="${next_link}">Next Page »</a>
% endif
</br>
</div>
<div id="col_2"></div>
