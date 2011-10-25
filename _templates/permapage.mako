<%inherit file="site.mako" />

<div id="col_1">
    <%include file="post.mako" args="post=post,resume=False,col2=False" />
    <div id="disqus_thread"></div>
    <script type="text/javascript">
      var disqus_url = "${post.permalink}";
    </script>
    % if bf.config.blog.disqus.enabled:
    <script type="text/javascript" src="http://disqus.com/forums/${bf.config.blog.disqus.name}/embed.js"></script>
    <noscript><a href="http://${bf.config.blog.disqus.name}.disqus.com/?url=ref">View the discussion thread.</a></noscript><a href="http://disqus.com" class="dsq-brlink">blog comments powered by <span class="logo-disqus">Disqus</span></a>
    % endif
</div>

<div id="col_2">
    <%include file="post.mako" args="post=post,resume=False,col2=True" />
</div>

