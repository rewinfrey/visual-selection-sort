class SelectionSort
  constructor: (@canvas_height, @canvas_width, @stroke)->
    this.data            = []
    this.sorted          = []
    this.animation_list  = new LinkedList()
    this.canvas_height   = @canvas_height
    this.canvas_width    = @canvas_width
    this.stroke          = @stroke
    
  construct_array: ->
    while this.data.length < (parseInt(this.canvas_width / this.stroke))
      this.data.push(new Node(this.data.length, parseInt((Math.random() * 1000 % this.canvas_height - 50) + 50)))

  first_unsorted_index: ->
    for element, index in this.data
      if element.state == "unsorted"
        return index
    return null
  
  swap_elements: (minimum) ->
    first       = this.first_unsorted_index()
    first_y     = this.data[first].y

    this.animation_list.add_animation_node(this.data[first], "swap")
    this.animation_list.add_animation_node(this.data[minimum], "swap")
    this.animation_list.add_animation_node(this.data[first], "swap")
    this.animation_list.add_animation_node(this.data[minimum], "swap")

    this.data[first].y     = this.data[minimum].y
    this.data[minimum].y   = first_y
    this.data[first].state = "sorted"

    this.animation_list.add_animation_node(this.data[first], "swap")
    this.animation_list.add_animation_node(this.data[minimum], "swap")
    this.animation_list.add_animation_node(this.data[first], "swap")
    this.animation_list.add_animation_node(this.data[minimum], "swap")

    if minimum == first
      this.animation_list.add_animation_node(this.data[first], "sorted")
    else
      this.animation_list.add_animation_node(this.data[minimum], "unsorted")
      this.animation_list.add_animation_node(this.data[first], "sorted")

  selection_sort: ->
    minimum = this.first_unsorted_index()
    if minimum != null
      this.animation_list.add_animation_node(this.data[minimum], "minimum")
      for element, index in this.data
        if element.state != "sorted"
          if index != minimum
            this.animation_list.add_animation_node(this.data[index], "iteration")
            this.animation_list.add_animation_node(this.data[index], "unsorted")
          if element.y < this.data[minimum].y
            this.animation_list.add_animation_node(this.data[minimum], "unsorted")
            this.animation_list.add_animation_node(this.data[index], "minimum")
            minimum = index
      this.swap_elements(minimum)
      this.selection_sort()
    else
      return

class Node
  constructor: (@x, @y) ->
    this.x     = @x
    this.y     = @y
    this.prev  = null
    this.next  = null
    this.state = "unsorted"
    
  copy: ->
    temp_node = new Node(this.x, this.y)
    temp_node.prev = this.prev
    temp_node.next = this.next
    return temp_node

class LinkedList
  constructor: ->
    this.first  = null
    this.last   = null
    this.length = 0
    this.max    = 0

  # Specific to selection sort. Swap the found minimum node with the first node in the list
  selection_sort_swap: (min, sorted_list, animation_list) ->
    length = 0
    node   = this.first
    while length < this.length
      if min.x == node.x && min.y == node.y

        animation_list.add_animation_node(this.first, "swap")
        animation_list.add_animation_node(min, "swap")               

        min.y        = this.first.y
        this.first.y = node.y

        animation_list.add_animation_node(this.first, "swapped")
        animation_list.add_animation_node(min, "swapped")
        animation_list.add_animation_node(this.first, "unsorted")
        animation_list.add_animation_node(min, "unsorted")
        return
      node = node.prev
      length += 1

  # set the first pointer to the second node in the linked list, return the first node and reduce the length by one
  remove_node: (node) ->
    if this.length > 1
      if node == this.first
        this.first = node.prev
      if node == this.last
        this.last  = node.next
    else
      this.first = null
      this.last  = null
    # node.prev = null
    # node.next = null
    this.length -= 1
  
  # adds a new node to a linked list. first node is "next" to last node
  # first_node.prev -> second_node.prev -> third_node ...
  # first_node <- second_node.next <- third_node.next
  add_node: (node) ->
    if this.length == 0
      node.prev  = node
      node.next  = node
      this.first = node
      this.last  = node
    else
      this.first.next = node
      this.last.prev  = node
      node.prev       = this.first
      node.next       = this.last
      this.last       = node
    this.length += 1
    
  # checks if the linked list is empty (meaning the linked list length is == 0)
  is_empty: ->
    return this.length == 0

  add_animation_node: (node, state) ->
    temp_node       = new Node(node.x, node.y)
    temp_node.state = state
    this.add_node(temp_node)
    

class Animate
  constructor: (@id, @canvas_height, @canvas_width, @stroke, @frame_rate) ->
    this.ctx        = document.getElementById("#{@id}").getContext("2d")
    this.height     = @canvas_height
    this.width      = @canvas_width
    this.stroke     = @stroke
    this.list_size  = 0
    this.frame_rate = @frame_rate

  reset_canvas: ->
    this.ctx.clearRect(0, 0, this.height, this.width)

  get_list_size: (linked_list) ->
    this.list_size = linked_list.length

  draw_linked_list: (linked_list) ->
    length = 0
    current_node = linked_list.first
    while length < linked_list.length
      this.ctx.clearRect(current_node.x * this.stroke, 0, this.stroke, this.height)
      this.ctx.fillStyle = "rgb(45,123,200)"
      this.ctx.fillRect(current_node.x * this.stroke, this.height - current_node.y, this.stroke, current_node.y)
      current_node = current_node.prev
      length += 1

  draw_array: (array) ->
    for element, element_index in array
      this.ctx.clearRect(element.x * this.stroke, 0, this.stroke, this.height)
      this.ctx.fillStyle = "rgb(45,123,200)"
      this.ctx.fillRect(element.x * this.stroke, this.height - element.y, this.stroke, element.y)
      
  draw_frame: (current_node) ->
    switch current_node.state
      when "unsorted"
        this.ctx.clearRect(current_node.x * this.stroke, 0, this.stroke, this.height)
        this.ctx.fillStyle = "rgb(45,123,200)"
        this.ctx.fillRect(current_node.x * this.stroke, this.height - current_node.y, this.stroke, current_node.y)
      when "sorted"
        this.ctx.clearRect(current_node.x * this.stroke, 0, this.stroke, this.height)
        this.ctx.fillStyle = "rgb(255,153,0)"
        this.ctx.fillRect(current_node.x * this.stroke, this.height - current_node.y, this.stroke, current_node.y)
      when "swap"
        this.ctx.clearRect(current_node.x * this.stroke, 0, this.stroke, this.height)
        this.ctx.fillStyle = "rgb(200,0,0)"
        this.ctx.fillRect(current_node.x * this.stroke, this.height - current_node.y, this.stroke, current_node.y)
      when "swapped"
        this.ctx.clearRect(current_node.x * this.stroke, 0, this.stroke, this.height)
        this.ctx.fillStyle = "rgb(200,150,0)"
        this.ctx.fillRect(current_node.x * this.stroke, this.height - current_node.y, this.stroke, current_node.y)
      when "iteration"
        this.ctx.clearRect(current_node.x * this.stroke, 0, this.stroke, this.height)
        this.ctx.fillStyle = "rgb(255,255,0)"
        this.ctx.fillRect(current_node.x * this.stroke, this.height - current_node.y, this.stroke, current_node.y)
      when "minimum"
        this.ctx.clearRect(current_node.x * this.stroke, 0, this.stroke, this.height)
        this.ctx.fillStyle = "rgb(100,200,100)"
        this.ctx.fillRect(current_node.x * this.stroke, this.height - current_node.y, this.stroke, current_node.y)
      else 
        this.ctx.clearRect(current_node.x * this.stroke, 0, this.stroke, this.height)
        this.ctx.fillStyle = "rgb(45,123,200)"
        this.ctx.fillRect(current_node.x * this.stroke, this.height - current_node.y, this.stroke, current_node.y)

  process_animation: (animation_list) ->
    if animation_list.length != 0
      new_frame = new Node(animation_list.first.x, animation_list.first.y)
      new_frame.state = animation_list.first.state
      this.draw_frame(new_frame)
      animation_list.remove_node(animation_list.first)
      window.setTimeout(
        () =>
          this.process_animation(animation_list)
        ,
          this.frame_rate
      )

$(document).ready () ->
  # number in milliseconds to pause between animation frames
  frame_rate    = 75
  
  # number in pixels to determine width of data set lines
  stroke        = 35
  canvas_height = parseInt($('#selection_sort').css('height').replace("px", ""))
  canvas_width  = parseInt($('#selection_sort').css('width').replace("px", ""))

  animate            = new Animate("selection_sort", canvas_height, canvas_width, stroke, frame_rate)
  selection          = new SelectionSort(canvas_height, canvas_width, stroke)
  sorted_list        = new LinkedList()
  animation_list     = new LinkedList()
  
  # data array created belongs to the selection object
  selection.construct_array()
  
  # data array is passed to an animate object to be drawn
  animate.draw_array(selection.data)
  
  # data array is sorted (via a selection sort) on the selection object's data array
  selection.selection_sort()
  
  # a animation linked list created during the selection sort is passed to our animate object
  animate.process_animation(selection.animation_list)