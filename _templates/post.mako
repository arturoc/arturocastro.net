<%page args="post,resume,col2"/>
% if not col2:
    <div class="blog_post">
      <a name="${post.slug}"></a>
      <h2 class="blog_post_title"><a href="${post.permapath()}" rel="bookmark" title="Permanent Link to ${post.title}">${post.title}</a></h2>
      <small>${post.date.strftime("%B %d, %Y at %I:%M %p")} | categories: 
    <% 
       category_links = []
       for category in post.categories:
           if post.draft:
               #For drafts, we don't write to the category dirs, so just write the categories as text
               category_links.append(category.name)
           else:
               category_links.append("<a href='%s'>%s</a>" % (category.path, category.name))
    %>
    ${", ".join(category_links)}
    % if bf.config.blog.disqus.enabled:
     | <a href="${post.permalink}#disqus_thread">View Comments</a>
    % endif
    </small><p/>
      <div class="post_prose">
        ${self.post_prose(post,resume)}
      </div>
      
    % if resume:
        <p><a href="${post.permapath()}">more >></a></p>
    % endif
    </div>
% else:
    ${self.post_col2(post)}
% endif


<%def name="post_prose(post,resume)">
    <%
    post_text = u""
    more_pos = post.content.find('--more--')
    col2_pos = post.content.find('--col2--')
    if resume and more_pos!=-1:
        post_text = post.content[:more_pos]
    elif not resume:
        if col2_pos!=-1:
            post_text = post.content[:more_pos] + post.content[more_pos+8:col2_pos]
        else:
            post_text = post.content[:more_pos] + post.content[more_pos+8:]
    else:
        if col2_pos!=-1:
            post_text = post.content[:col2_pos]
        else:
            post_text = post.content
    %>
    ${post_text}
</%def>

<%def name="post_col2(post)">
    <%
    col2_text = u""
    col2_pos = post.content.find('--col2--')
    if col2_pos!=-1:
        col2_text = post.content[col2_pos + 8:]
    %>
    ${col2_text}
</%def>
