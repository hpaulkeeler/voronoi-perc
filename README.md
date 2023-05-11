# voronoi-perc

The code runs simulations of a percolation (network) model conisting of a Voronoi (or Dirichlet) tessellation (or diagram) constructed from a homogeneous point process. 

The edges and vertices of the Voronoi tessellation naturlly form a graph (or network). In recent work, this random geometric stucture has been used to model a city, where the graph's edges and vertices represent the city's streets and crossroads (or street intersections) respectively. 

The code was written to run simulations of a Poisson-Voronoi network model based on the signal-to-interference-plus-noise (SINR). The results are presented in the 2023 work by Cali, Keeler and Blaszczyszyn [1].

## Motivation
Imagine a city with phone relay stations, located at various crossroads (or street intersections), and, scattered along each street are people willing to relay data through their devices, forming a large device-to-device network. Can we relay data through such a network? What happens when the number of people on the streets increases? How does the network connectivity behave?  This code runs Poisson-Voronoi network simumations, producing numerical results that highlight how increasing the user (or device)  density  can increase overall  network connectivity, but too many users will eventually destroy the connectivity due to interference. We place a focus on  network connectivity and the ability to reduce interference in the network. 

Early random models of wireless networks assume that communication between a  transmitter and receiver could happen if they were within some fixed distance $r$ of each other. Gilbert used this assumption to create a pioneering percolation model, which created the field of continuum percolation. But in recent years researchers have used the signal-to-inteference-plus-noise (SINR) ratio to model wireless networks. This approach is arguably more realistic. Using everyday language, in a room full of people trying to speak to you, it is not simply the closeness of a single speaker that dictates your ability to hear them, but rather their distance and volume compared to the total interference of everyone else trying to speak to you. 

## Model description
Take a homogeneous Poisson point process and construct a Voronoi tesselation, which will represent a street layout (or system) of a large city. The edges and vertices represent streets and crossroads (or street intersections) respectively. Then relays (or phone relay stations) and users (or devices of users) are added to street layout.

Relays are located at crossroads (or street intersections), whereas users are scattered along streets. Between any two adjacent relays, we assume data can be transmitted either directly between the relays or through users, given they share a common street. More specificcally, relays are located independently with probability p, whereas users are located on streets according to independent (one-dimensional) homogeneous Poisson point processes.

This percolation model uses a line-of-sight requirement, where relays and users (or devices) can only communicate with each other when they share a street. The model also uses a connectivity requirement that is purely geometric, where users and relays can only communicate with each other if they are within some fixed distance of each other, which is a variation of the classic Gilbert model that created continuum percolation theory.

## Another Poisson-Voronoi percolation model
The model presented here is not the same as the site percolation model based on Poisson-Voronoi tessellation, which is a tiling percolation model. Under this model, each cell of a Poisson-Voronoi tessellation is coloured one colour, say, black independently from all other cells with some fixed probability p. Then the random tiling of black cells is examined. Bollobás and Riordan gave an exact result for percolation probability of this model.


## Relevant literature

 [1] Cali, Keeler, and Blaszczyszyn, _Connectivity and interference in device-to-device networks in Poisson-Voronoi cities_, 2023.
 
 [2] Le Gall, Błaszczyszyn, Cali, and Taoufik, _The influence of canyon shadowing on device-to-device connectivity in urban scenario_, 2019
 
 [3] Le Gall, Błaszczyszyn, Cali, and Taoufik, _Continuum line-of-sight percolation on Poisson--Voronoi tessellations_, 2021.
 
 [4] Bollobás, Riordan, _The critical probability for random Voronoi percolation in the plane is 0.5_, 2006. (Preprint: https://arxiv.org/abs/math/0410336)
 
 ## Useful links
 
 https://en.wikipedia.org/wiki/Poisson_point_process
 
 https://en.wikipedia.org/wiki/Voronoi_diagram
