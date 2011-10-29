---
categories: c++ DataStructures Tutorials
date: 2011/10/28 21:10:00
title: stl::vector
---

A stl::vector is the equivalent in c++ to a c array. Everything that can be done with a vector can be done with a c array and viceversa[[1]](#1) the only difference between them is that the vector interface is object oriented, which means that your code will be cleaner and easier to understand. I'm going to explain here some aspects of it's inner workings trying to make it clearer how to use a vector in a safe and fast way.

--more--

### reserve() and capacity() vs resize() and size()

reserve() makes the vector allocate memory internally but that doesn't mean that that memory is being used yet. We can know how much memory a vector has allocated by calling capacity().

resize() allocates memory if it's necesary and it also marks it as used. We can know how much elements are in use by calling size():

$$code(lang=c++)
vector<int> v;
v.reserve(50);
cout << v.capacity() << endl;    // will print 50
cout << v.size() << endl;        // will print 0

v.push_back(1);
cout << v.capacity() << endl;    // will print 50
cout << v.size() << endl;        // will print 1

v.resize(100);
cout << v.capacity() << endl;    // will print 100
cout << v.size() << endl;        // will print 100
$$/code

clear() is also related to the number of used elements, not to the allocated memory. So if we call clear we are actually telling that no memory is in use but there's actually no memory deletion: __vectors' allocated memory never shrinks__[[2]](#2):


$$code(lang=c++)
vector<int> v;
v.reserve(50);
cout << v.capacity() << endl;    // will print 50
cout << v.size() << endl;        // will print 0

v.push_back(1);
cout << v.capacity() << endl;    // will print 50
cout << v.size() << endl;        // will print 1

v.clear();
cout << v.capacity() << endl;    // will print 50
cout << v.size() << endl;        // will print 0
$$/code

So calling clear is actually fast and reusing a vector is faster than creating a new one cause the memory is already allocated.


### push_back()

The push_back method of a vector inserts a new element at the end, but, what happens with memory internally? Well, even if the size of the vector increases by one __vectors' capacity grows exponentially__[[2]](#2):

$$code(lang=c++)
vector<int> v;
v.push_back(1);
cout << v.capacity() << endl;  // will print 1
cout << v.size() << endl;      // will print 1

v.push_back(1);
cout << v.capacity() << endl;  // will print 2
cout << v.size() << endl;      // will print 2

v.push_back(1);
cout << v.capacity() << endl;  // will print 4 <<<
cout << v.size() << endl;      // will print 3

v.push_back(1);
cout << v.capacity() << endl;  // will print 4
cout << v.size() << endl;      // will print 4

v.push_back(1);
cout << v.capacity() << endl;  // will print 8 <<<
cout << v.size() << endl;      // will print 5
$$/code

A vector behaves like this to make things faster, and it makes things faster for 2 reasons:

- __Allocating memory is slow__ but it's equally slow no matter how much memory we are allocating[[3]](#3)
- __All the elements in a vector are contiguous in memory__. When we push back a new element it has to be after the last one. So if there's no more unallocated memory after the last element, the vector needs to move all the elements that it already contained to a new position. Moving all the elements actually means: allocating new memory, copying all the elements to the new location and deleting the old memory, which is really, really slow

As it can be seen in the previous code, whenever there's no more space left in the vector, and we add a new element, it doubles the size of the allocated memory, that way we can keep adding elements for a while without reallocations.

Now if we print the address in memory of the first element after pushing back new ones, we'll see that probably[[4]](#4), after exhausting the capacity, the vector moves it's elements to a new location in memory:

$$code(lang=c++)
vector<int> v;
v.push_back(1);
cout << v.capacity() << endl;  //will print out 1
cout << &v[0] << endl          //will print some address

v.push_back(1);
cout << v.capacity() << endl;  //will print out 2
cout << &v[0] << endl          //will probably print a different address

v.push_back(1);
cout << v.capacity() << endl;  //will print out 4 <<<
cout << &v[0] << endl          //will probably print a different address

v.push_back(1);
cout << v.capacity() << endl;  //will print out 4
cout << &v[0] << endl          //will print the same address

v.push_back(1);
cout << v.capacity() << endl;  //will print out 8 <<<
cout << &v[0] << endl          //will probably print a different address
$$/code

This is very important for several resons: as i've told before the exponential growth makes thing faster, but even with that, allocating new memory and moving the elements around is slow. So if you know you are going to have at least 50 elements it's better to reserve that memory or more before beginning to add elements:

$$code(lang=c++)
vector<int> v;
v.reserve(50);
v.push_back(1);
//...
$$/code

That way there's going to be no memory reallocation till we push back 50 elements.

### push_back() is slow

Try to avoid it if you are going to add lots of elements. For the reasons mentioned above this:

$$code(lang=c++)
vector<int> v;

for(int i=0;i<100;i++){
    v.push_back(1);
}
$$/code

is way slower than:

$$code(lang=c++)
vector<int> v;

v.resize(100);
for(int i=0;i<100;i++){
    v[i] = 1;
}
$$/code

Use the second!

Even this:

$$code(lang=c++)
vector<int> v;
v.reserve(100);

for(int i=0;i<100;i++){
    v.push_back(1);
}
$$/code

is slightly slower since push_back has to check if there's still memory available while when using the [] operator there's no check.

If you are adding a few elements at a time or one by one and don't know how many you'll have then push_back is the best because of the exponential growth. For example:

$$code(lang=c++)
class Shape{
public:
void addVertex(Point p){
    points.push_back(p);
}

private:
vector<Point> points;
}
$$/code

is correct, trying to optimize it by using resize() like:

$$code(lang=c++)
void addVertex(Point p){
    points.resize(points.size()+1);
    points[points.size()-1] = p;
}
$$/code

will usually be slower since it will do more memory allocations in the long term.

### push_front() is super slow

A vector only grows from the end, if we add elements in the front it actually moves all the elements one position and adds the new element. So unless you are not concerned with performance don't use push_front. If you need to add elements both in the front and the back very often, then you probably want to use a list or a deque.

If you only need to add elements in the front, add them in the back and go through the vector in the opposite direction.


### pointers to elements in vectors: __Don't__!

As i've said above things in a vector move when it needs more memory to grow, so pointers to elements in a vector can and probably will become invalid:

$$code(lang=c++)
vector<int> v;
v.push_back(1);
int * p = &v[0];

for(int i=0;i<100;i++){
    v.push_back(1);
}

cout << p << endl;
cout << &v[0] << endl;  // will surely be different than p
$$/code

We can solve it by using vectors of pointers, storing positions in the vector, using std lists or using a vector as if it was a static array.


### using a vector as if it was a static array

In c++ as a general rule, don't use arrays, a vector can do the same and the syntax is more understandable.

If for any reason you are thinking in using an array instead of a vector, you can always use a vector as if it was an array, just don't use push_back:

$$code(lang=c++)
vector<int> v(100);

for(int i=0;i<100;i++){
    v[i] = 1;
}
$$/code

What's the advantage of this over a plain c array? well, mainly it's easier to use, for example to copy the contents of a vector to another:

$$code(lang=c++)
vector<int> v(100);
//...
vector<int> v2 = v;
$$/code

while with arrays:

$$code(lang=c++)
int v[100];
//...
int v2[100];
memcpy(v2,v,100*sizeof(int));
$$/code

Or for example to pass an array as a parameter to a function you need to pass it's size in a different argument:

$$code(lang=c++)
void doSomething(int * array, int size){
...
}
$$/code

and at the same time you have to keep that size in some variable making your code more complex. A vector carries it's size in it self, that's called encapsulation and it's the main reasons to use a vector over an array.

### vectors and threads

I'm not going to enter into how threads work here but when working with threads and stl vectors keep in mind that:

- If you use a vector as an array, as explained above, you don't need to lock[[5]](#5), you won't get crashes. 
- If you need to change the vector size, then lock always that you access the vector elements both for reading and writing. And, very important, also when you access it's size. 
- If you check the size and then access the vector relying on the retrieved size, do it in the same lock. If not, the size can change while you unlock and lock again

Also this post in the OF forum explains lots of details about threads and memory access:

[http://forum.openframeworks.cc/index.php?topic=7248.0](http://forum.openframeworks.cc/index.php?topic=7248.0O)


### an OF example

Here's an OF example that demoes the concepts explained in this article. 

[https://github.com/arturoc/memoryExamples](https://github.com/arturoc/memoryExamples)


<a name="1">[1]</a>: Yes, a c array can also grow by using malloc, realloc and free instead of new and delete.

<a name="2">[2]</a>: Theoretically the statements in this article about memory growing are dependent on the particular implementation but all the implementations i know behave like this.

<a name="4">[4]</a>: This is a simplification but for most cases with vectors it's true

<a name="4">[4]</a>: Sometimes, mostly when the vector is still small, there's enough unused memory after the last element and no reallocation is needed but most of the times when the vector changes it's internal size it needs to move it's elements to a new location.

<a name="5">[5]</a>: There's other reasons for locking apart from having crashes, most of them explained in the forum thread in the link above.

