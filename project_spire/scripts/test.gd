@tool

extends EditorScript

var array1=[Vector2(2,5), Vector2(3,5), Vector2(5,5), Vector2(6,5), Vector2(7,4), Vector2(6,4), Vector2(5,4), Vector2(4,4), Vector2(3,4), Vector2(2,4), Vector2(1,4), Vector2(1,3), Vector2(3,3), Vector2(4,3), Vector2(5,3), Vector2(7,3), Vector2(7,2), Vector2(6,2), Vector2(5,2), Vector2(3,2), Vector2(2,2), Vector2(1,2), Vector2(1,1), Vector2(2,1), Vector2(3,1), Vector2(4,1), Vector2(5,1), Vector2(6,1), Vector2(7,1), Vector2(7,0), Vector2(6,0), Vector2(5,0), Vector2(4,0), Vector2(3,0), Vector2(2,0), Vector2(1,0)]
var array1_healths=[]

var array2=[Vector2(5,3), Vector2(6,3), Vector2(7,3), Vector2(8,3), Vector2(8,2), Vector2(7,2), Vector2(6,2), Vector2(5,2), Vector2(5,1), Vector2(6,1), Vector2(7,1), Vector2(8,1), Vector2(8,0), Vector2(7,0), Vector2(6,0), Vector2(5,0)]
var array2_healths=[]

var array3=[Vector2(3,0), Vector2(4,0), Vector2(5,0), Vector2(5,1), Vector2(4,1), Vector2(3,1), Vector2(2,1), Vector2(6,1), Vector2(8,2), Vector2(0,2), Vector2(1,3), Vector2(2,4), Vector2(6,4), Vector2(7,3), Vector2(5,5), Vector2(3,5)]
var array3_healths=[]

func _run():
	health_array_builder()
	array_sum()
	array_size()
	
func health_array_builder():
	for i in array1.size():
		array1_healths.append(1)
	print("array1_healths:"+str(array1_healths))
	for i in array2.size():
		array2_healths.append(1)
	print("array2_healths:"+str(array2_healths))
	for i in array3.size():
		array3_healths.append(1)
	print("array3_healths:"+str(array3_healths))

func array_sum():
	var array3=[2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	var sum=0
	for i in array3.size():
		sum=sum+array3[i]
	print("sum:"+str(sum))
	print("array_size:"+str(array3.size()))

func array_size():
	var array4=[Vector2(0,4), Vector2(1,4), Vector2(2,4), Vector2(6,4), Vector2(7,4), Vector2(8,4), Vector2(3,3), Vector2(2,3), Vector2(1,3), Vector2(0,3), Vector2(5,3), Vector2(6,3), Vector2(7,3), Vector2(8,3), Vector2(0,2), Vector2(1,2), Vector2(2,2), Vector2(3,2), Vector2(4,2), Vector2(5,2), Vector2(6,2), Vector2(7,2), Vector2(8,2), Vector2(7,1), Vector2(6,1), Vector2(5,1), Vector2(4,1), Vector2(3,1), Vector2(2,1), Vector2(1,1), Vector2(1,0), Vector2(2,0), Vector2(3,0), Vector2(4,0), Vector2(5,0), Vector2(6,0), Vector2(7,0)]
	print("array4_size:"+str(array4.size()))
