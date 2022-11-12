# cloud-armor
Realizamos varios ejercicios para probar distintas politicas de Cloud Armor

SQLinjecttion
  - Desde Login ingresamos:  'or TRUE --
  - Esto debería permitirnos acceder sin credenciales a nuestro portal
  
Creamos en Cloud Armor la politica:
  + evaluatePreconfiguredExpr('sqli-v33-stable')
  
Cross-Sire Scription
  - Desde "Customer Feedback", en el campo "Comment" ingresamos:
  - <iframe src="javascript:alert('xss attack')"
  
Creamos en Cloud Armor la politica:

  + evaluatePreconfiguredExpr('xss-v33-stable')
  
  
Restringir accesso a un path
   - desde nuestr url agregamos la ruta "/ftp", veremos en contenido de este directorio
   
Creamos en Cloud Armor la politica:

  + request.path.matches('/ftp')


Idea original tomada de https://www.youtube.com/watch?v=RsXbmOb3L2E
