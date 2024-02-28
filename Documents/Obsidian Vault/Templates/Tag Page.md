<%*
let finalOutput="";const baseTag=tp.frontmatter.aliases||"DefaultBaseTag",allTags=Object.entries(app.metadataCache.getTags()),tagPageTags=allTags.filter(a=>a[0].startsWith(baseTag)).sort((a,t)=>a[0].localeCompare(t[0]));tagPageTags.forEach(a=>{let t=a[0].split(",")[0];finalOutput+=`${t}
`}),tR+=`${finalOutput}`;
%>
<%* tR %>