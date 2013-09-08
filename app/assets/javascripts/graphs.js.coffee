jQuery ->

	coords = []
	coordsN = -1
	queue = []

	vectorAdd = (x, y, i, o) ->
		a = if i >= Math.PI then i - Math.PI + o else i + Math.PI + o
		a = if a >= 2*Math.PI then a - 2*Math.PI else a
		{ x: x + Math.cos(a), y: y + Math.sin(a), o: a }

	findNode = (nodes, i) ->
		for node in nodes
			if node.id is i
				return node

	nodeExists = (i) ->
		exists = false
		for c in coords
			if c[i]
				exists = true
		return exists

	bfs = (node, edges, first) ->
		if first
			coordsN++
			coords.push {}
			coords[coordsN][node.id] = { x: 0, y: 0, o: Math.PI }
		toAdd = []
		for edge in edges
			if edge.parent_id is node.id
				toAdd.push edge
		numE = if first then toAdd.length else toAdd.length + 1
		diff = 2*Math.PI / numE
		offset = if first then 0 else 1
		for edge, i in toAdd
			if not nodeExists(edge.child_id)
				coords[coordsN][edge.child_id] = vectorAdd(coords[coordsN][node.id].x, coords[coordsN][node.id].y, coords[coordsN][node.id].o, diff * (i + offset))
				queue.push edge.child_id

	sigRoot = document.getElementById('sig')
	sigInst = sigma.init(sigRoot)

	drawGraph = ->
		$.ajax
			method: "GET",
			url: window.location.pathname,
			dataType: "json",
			success: (data) ->
				mainColor = Math.floor(Math.random() * 360)

				sigma.publicPrototype.degreeToSize = ->
					biggest = 0
					this.iterNodes (node) ->
						node.size = node.degree
						if node.degree > biggest
							biggest = node.degree
					this.iterNodes (node) ->
						node.color = tinycolor("hsv(" + mainColor + ", " + (Math.floor(100 * node.degree / biggest)) + "%, " + (Math.floor(100 * node.degree / biggest)) + "%)").toHex()
					this.drawingProperties
						labelThreshold: biggest * 2

				sigInst = sigma.init(document.getElementById('sig'))

				sigInst.drawingProperties
					defaultLabelColor: '#fff',
					defaultLabelSize: 16,
					defaultLabelBGColor: '#fff',
					defaultLabelHoverColor: '#000',
					font: 'Century Gothic',
				sigInst.graphProperties
					minNodeSize: 1,
					maxNodeSize: 10
				sigInst.mouseProperties
					mouseEnabled: true

				greyColor = "#444"
				sigInst.bind('overnodes', (event) ->
					ns = event.content
					neighbors = {}
					sigInst.iterEdges (e) ->
						if ns.indexOf(e.source) < 0 && ns.indexOf(e.target) < 0
							if not e.attr['grey']
								e.attr['true_color'] = e.color
								e.color = greyColor
								e.attr['grey'] = 1
						else
							e.color = if e.attr['grey'] then e.attr['true_color'] else e.color
							e.attr['grey'] = 0
							neighbors[e.source] = 1
							neighbors[e.target] = 1
					sigInst.iterNodes (n) ->
						if not neighbors[n.id]
							if not n.attr['grey']
								n.attr['true_color'] = n.color
								n.color = greyColor
								n.attr['grey'] = 1
								n.forceLabel = false
						else
							n.color = if n.attr['grey'] then n.attr['true_color'] else n.color
							n.attr['grey'] = 0
							n.forceLabel = true
					sigInst.draw(2, 2, 2)
				).bind('outnodes', ->
					sigInst.iterEdges (e) ->
						e.color = if e.attr['grey'] then e.attr['true_color'] else e.color
						e.attr['grey'] = 0
					sigInst.iterNodes (n) ->
						n.color = if n.attr['grey'] then n.attr['true_color'] else n.color
						n.attr['grey'] = 0
						n.forceLabel = false
					sigInst.draw(2,2,2)
				).bind 'downnodes', (event) ->
					ns = event.content
					sigInst.iterNodes (n) ->
						if ns.indexOf(n.id) >= 0
							window.open(n.attr['url'],'_blank');

				graph = data["graph"]
				nodes = data["nodes"]
				edges = data["edges"]

				for node in nodes
					if not coords[coordsN] and not nodeExists(node.id) and queue.length is 0
						bfs node, edges, true
						while queue.length isnt 0
							bfs findNode(nodes, queue.shift()), edges, false
						minX = 9001
						maxX = -9001
						minY = 9001
						maxY = -9001
						for k,v of coords[coordsN]
							if v.x < minX
								minX = v.x
							if v.x > maxX
								maxX = v.x
							if v.y < minY
								minY = v.y
							if v.y > maxY
								maxY = v.y
						rangeX = if maxX - minX is 0 then 1 else maxX - minX
						rangeY = if maxY - minY is 0 then 1 else maxY - minY
						for k,v of coords[coordsN]
							console.log "x: " + (v.x - minX) / rangeX
							console.log "y: " + (v.y - minY) / rangeY
							n = findNode(nodes, parseInt(k))
							sigInst.addNode n.id,
								label: n.title,
								x: (v.x - minX) / rangeX,
								y: (v.y - minY) / rangeY,
								url: n.url,
								group: coordsN
						for edge in edges
							if nodeExists(edge.parent_id) and nodeExists(edge.child_id)
								sigInst.addEdge edge.parent_id + '-' + edge.child_id, edge.parent_id, edge.child_id,
									size: 2
				console.log coords

				sigInst.degreeToSize()
				sigInst.activateFishEye().draw()

	drawGraph()

	$(window).resize ->
		# sigInst.iterEdges (e) ->
		# 	sigInst.dropEdge(e)
		# sigInst.iterNodes (n) ->
		# 	sigInst.dropNode(n)
		# # $("#sig").empty()
		# # drawGraph()