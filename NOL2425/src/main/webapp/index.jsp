<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<title>Bienvenid@ a Notas OnLine</title>
		<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css">
		<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    	<link href="<%= request.getContextPath() %>/css/estilos.css" rel="stylesheet" type="text/css">
	</head>
	<body>
		<div class="container py-5">
		    <header class="text-center mb-5 rounded shadow-sm">
				<div class="bg-primary text-white py-4 rounded">
					<h1 class="display-5">
						<i class="bi bi-mortarboard-fill me-3"></i>Bienvenid@ a <em>Notas OnLine</em>
					</h1>
					<p class="lead mb-0">
						<strong>Una aplicación que cuesta más de lo que parece para conseguir menos de<br> 
						lo que creías... ¿¡Qué más se puede pedir!?</strong>
					</p>
				</div>
		    </header>
		    
			<!-- Secciones de acceso -->
			<div class="row g-4">
				<div class="col-md-8">
					<div class="card h-100">
						<div class="card-body">
							<div class="mb-5">
								<h2 class="card-title text-primary">
									<i class="bi bi-mortarboard-fill me-2"></i>Si eres alumn@...
								</h2>
								<p class="card-text">
									Podrás <a href="<%= request.getContextPath() %>/alumno" class="btn btn-primary btn-sm">consultar <i class="bi bi-arrow-right"></i></a> 
									tus calificaciones... Debes contar con tus datos identificativos para acceder.
								</p>
							</div>

							<div>
								<h2 class="card-title text-success">
									<i class="bi bi-person-workspace me-2"></i>Si eres profesor@...
								</h2>
								<p class="card-text">
									Podrás <a href="<%= request.getContextPath() %>/profesor" class="btn btn-success btn-sm me-2">consultar <i class="bi bi-search"></i></a> 
									las calificaciones en tus asignaturas y modificarlas ... Debes contar con tus datos identificativos para acceder.
								</p>
							</div>
						</div>
					</div>
				</div>

				<!-- Grupo listado -->
				<div class="col-md-4">
					<div class="card h-100">
						<div class="card-header bg-primary text-white">
							<h5 class="card-title mb-0">
								<i class="bi bi-people-fill me-2"></i>Grupo G4_labo_Lunes
							</h5>
						</div>
						<div class="card-body">
							<ol class="list-group list-group-numbered">
								<li class="list-group-item">Cano Moya, Yeray</li>
								<li class="list-group-item">Genés Bastidas, Rubén</li>
								<li class="list-group-item">Makmar, Laila</li>
								<li class="list-group-item">Marín Hernández, José</li>
							</ol>
						</div>
					</div>
				</div>
			</div>
		
			<!-- Pie de página -->
			<footer class="mt-5 py-3 text-center border-top">
				<p class="mb-0">
					<i class="bi bi-code-slash me-2"></i>
					Trabajo en grupo realizado para la asignatura Desarrollo Web. Curso 2024-2025
				</p>
			</footer>
		</div>
		<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
	</body>
</html>