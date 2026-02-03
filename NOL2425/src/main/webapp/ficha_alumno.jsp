<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, dew.clases.Alumno, dew.clases.Asignatura" %>
<!DOCTYPE html>
<html>
<head>	
  <meta charset="UTF-8">
  <title>Ficha del Alumno</title>
	  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
	  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
	  <link href="./css/estilos.css" rel="stylesheet" type="text/css">
</head>
<body>
	  <div class="container py-4">
	    <!-- Header con estilo del index -->
	    <header class="text-center mb-5 rounded shadow-sm">
	      <div class="bg-primary text-white py-4 rounded">
	        <h1 class="display-5">
	          <i class="bi bi-person-vcard-fill me-3"></i>Ficha del Alumno
	        </h1>
	      </div>
	    </header>

	    <!-- Botón de Cerrar Sesión -->
            <div class="d-flex justify-content-end mb-4">
              <a href="/alumno?action=cierra" class="btn btn-outline-danger btn-sm" target="_self">
                <i class="bi bi-box-arrow-right me-2"></i>Cerrar sesión
              </a>
            </div>
	
              <%
				  Alumno alumno = (Alumno) request.getAttribute("alumno");
				  if (alumno == null) {
			  %>
	      <div class="alert alert-danger text-center">
	        No se pudo cargar la información del alumno.
	      </div>
			  <%
				  return;
				  }
			  %>

	    <div class="panel">
	      <!-- DATOS PERSONALES -->
	      <div class="info-block">
	        <h3 class="mb-4">
	          <i class="bi bi-person-badge me-2 text-primary"></i>
	          Datos Personales
	        </h3>
	        <div class="row">
	          <div class="col-md-8">
	            <div class="datos-field mb-3">
	              <label class="fw-bold">Nombre</label>
	              <div class="datos-value">${alumno.nombre}</div>
	            </div>
	            <div class="datos-field mb-3">
	              <label class="fw-bold">Apellidos</label>
	              <div class="datos-value">${alumno.apellidos}</div>
	            </div>
	            <div class="datos-field">
	              <label class="fw-bold">DNI</label>
	              <div class="datos-value">${alumno.dni}</div>
	            </div>
	          </div>
	          <div class="col-md-4">
	            <img src="./img/<%= alumno.getDni() + ".jpeg" %>" 
	                 alt="Foto de <%= alumno.getNombre() %>"
	                 class="img-fluid rounded student-photo">
	          </div>
	        </div>
            </div>
	
	      <!-- ASIGNATURAS MATRICULADAS -->
	      <div class="info-block mt-4">
	        <h3 class="mb-4">
	          <i class="bi bi-journal-text me-2 text-success"></i>
	          Asignaturas Matriculadas
            </h3>
            <div class="table-responsive">
	          <table class="table table-hover align-middle mb-0">
                <thead>
                  <tr>
                    <th>Asignatura</th>
                    <th>Nota</th>
                    <th class="text-center">Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <%
                    List<Asignatura> lista = alumno.getAsignaturas();
                    if (lista != null && !lista.isEmpty()) {
                      for (Asignatura asig : lista) {
                  %>
                  <tr>
	                <td><%= asig.getAcronimo() %></td>
                    <td>
                      <%
                        String nota = asig.getNota();
                        out.print((nota == null || nota.isEmpty()) ? "—" : nota);
                      %>
                    </td>
                    <td class="text-center">
	                  <a class="btn btn-outline-primary btn-sm"
	                     href="<%= request.getContextPath() %>/asignatura?acronimo=<%= asig.getAcronimo() %>">
	                    <i class="bi bi-eye me-1"></i>Ver detalles
                      </a>
                    </td>
                  </tr>
                  <%
                      }
                    } else {
                  %>
                  <tr>
	                <td colspan="3" class="text-center">No hay asignaturas matriculadas</td>
                  </tr>
                  <% } %>
                </tbody>
              </table>
            </div>
        </div>        
        <div class="text-end my-3">
		  	<a href="${pageContext.request.contextPath}/alumno?action=verCertificado"
			   class="btn btn-outline-success">
			  <i class="bi bi-file-earmark-text me-1"></i> Ver Certificado Académico
			</a>
		</div>        
      </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>