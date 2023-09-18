#!/usr/bin/env lua5.1
-- -*- coding: utf-8 -*-

-- 3D “donut” shape rendering using floating-point math
-- see <https://www.a1k0n.net/2011/07/20/donut-math.html>

-- cargo-culted by erle 2023-09-18

local theta_spacing = 0.1  -- 0.07
local phi_spacing = 0.002  -- 0.02

local R1 = 1
local R2 = 2
local K2 = 5

local screen_height = 256
local screen_width = 256

local K1 = screen_width * K2 * 3 / ( 8 * ( R1 + R2 ) )

local output = {}
local zbuffer = {}

local grey = { 120, 120, 120 }
local gray = { 136, 136, 136 }

for y = 1,screen_height,1 do
   output[y] = {}
   zbuffer[y] = {}
   for x = 1,screen_width,1 do
      local hori = math.floor( ( (y - 1) / 32 ) % 2 )
      local vert = math.floor( ( (x - 1) / 32 ) % 2 )
      output[y][x] = hori ~= vert and grey or gray
      zbuffer[y][x] = 0
   end
end

function render_frame(A, B)
   -- precompute sines and cosines of A and B
   local cosA = math.cos(A)
   local sinA = math.sin(A)
   local cosB = math.cos(B)
   local sinB = math.sin(B)

   -- theta goas around the cross-sectional circle of a torus
   for theta=0, 2*math.pi, theta_spacing do
      -- precompute sines and cosines of theta
      local costheta = math.cos(theta)
      local sintheta = math.sin(theta)

      -- phi goes around the center of revolution of a torus
      for phi=0, 2*math.pi, phi_spacing do
        -- precompute sines and cosines of phi
         local cosphi = math.cos(phi)
         local sinphi = math.sin(phi)

         -- 2D (x, y) coordinates of the circle, before revolving
         local circlex = R2 + R1*costheta
         local circley = R1*sintheta

         -- 3D (x, y, z) coordinates after rotation
         local x = circlex*(cosB*cosphi + sinA*sinB*sinphi) - circley*cosA*sinB
         local y = circlex*(sinB*cosphi - sinA*cosB*sinphi) + circley*cosA*cosB
         local z = K2 + cosA*circlex*sinphi + circley*sinA

         local ooz = 1/z

         -- x and y projection
         local xp = math.floor(screen_width/2 + K1*ooz*x)
         local yp = math.floor(screen_height/2 + K1*ooz*y)

         -- calculate luminance
         local L = cosphi*costheta*sinB - cosA*costheta*sinphi - sinA*sintheta + cosB*( cosA*sintheta - costheta*sinA*sinphi )
         -- if (L > 0) then
         if (true) then
            if (ooz > zbuffer[yp][xp]) then
                   zbuffer[yp][xp] = ooz
                   local luminance = math.max( math.ceil( L * 180 ), 0 )
                   -- luminance is now in the range 0 to 255
                   r = math.ceil( (luminance + xp) / 2 )
                   g = math.ceil( (luminance + yp) / 2 )
                   b = math.ceil( (luminance + xp + yp) / 3 )
                   output[yp][xp] = { r, g, b }
            end
         end
      end
   end
end

dofile('init.lua')

render_frame(-0.7, 0.7)
tga_encoder.image(output):save("donut.tga")
