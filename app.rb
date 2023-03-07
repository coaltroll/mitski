require_relative 'http_server.rb'

server = HTTPServer.new(4567)

server.get('/banan/:name/dude') do |name|
	html = <<-HTML
		<!DOCTYPE html>
		<html lang="en">
		<head>
				<meta charset="UTF-8">
				<meta http-equiv="X-UA-Compatible" content="IE=edge">
				<meta name="viewport" content="width=device-width, initial-scale=1.0">
				<title>Document</title>
		</head>
		<body>
				<img src="/images/cat.jpg" alt="something went wrong">
				<h1> hello #{name} </h1>
		</body>
		</html>
	HTML

	html
end

server.start