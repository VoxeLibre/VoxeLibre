xof 0302txt 0064
// File created by CINEMA 4D

template Header {
 <3D82AB43-62DA-11cf-AB39-0020AF71E433>
 SWORD major;
 SWORD minor;
 DWORD flags;
}

template Vector {
 <3D82AB5E-62DA-11cf-AB39-0020AF71E433>
 FLOAT x;
 FLOAT y;
 FLOAT z;
}

template Coords2d {
 <F6F23F44-7686-11cf-8F52-0040333594A3>
 FLOAT u;
 FLOAT v;
}

template Matrix4x4 {
 <F6F23F45-7686-11cf-8F52-0040333594A3>
 array FLOAT matrix[16];
}

template ColorRGBA {
 <35FF44E0-6C7C-11cf-8F52-0040333594A3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
 FLOAT alpha;
}

template ColorRGB {
 <D3E16E81-7835-11cf-8F52-0040333594A3>
 FLOAT red;
 FLOAT green;
 FLOAT blue;
}

template IndexedColor {
 <1630B820-7842-11cf-8F52-0040333594A3>
 DWORD index;
 ColorRGBA indexColor;
}

template Boolean {
 <4885AE61-78E8-11cf-8F52-0040333594A3>
 SWORD truefalse;
}

template Boolean2d {
 <4885AE63-78E8-11cf-8F52-0040333594A3>
 Boolean u;
 Boolean v;
}

template MaterialWrap {
 <4885AE60-78E8-11cf-8F52-0040333594A3>
 Boolean u;
 Boolean v;
}

template TextureFilename {
 <A42790E1-7810-11cf-8F52-0040333594A3>
 STRING filename;
}

template Material {
 <3D82AB4D-62DA-11cf-AB39-0020AF71E433>
 ColorRGBA faceColor;
 FLOAT power;
 ColorRGB specularColor;
 ColorRGB emissiveColor;
 [...]
}

template MeshFace {
 <3D82AB5F-62DA-11cf-AB39-0020AF71E433>
 DWORD nFaceVertexIndices;
 array DWORD faceVertexIndices[nFaceVertexIndices];
}

template MeshFaceWraps {
 <4885AE62-78E8-11cf-8F52-0040333594A3>
 DWORD nFaceWrapValues;
 Boolean2d faceWrapValues;
}

template MeshTextureCoords {
 <F6F23F40-7686-11cf-8F52-0040333594A3>
 DWORD nTextureCoords;
 array Coords2d textureCoords[nTextureCoords];
}

template MeshMaterialList {
 <F6F23F42-7686-11cf-8F52-0040333594A3>
 DWORD nMaterials;
 DWORD nFaceIndexes;
 array DWORD faceIndexes[nFaceIndexes];
 [Material]
}

template MeshNormals {
 <F6F23F43-7686-11cf-8F52-0040333594A3>
 DWORD nNormals;
 array Vector normals[nNormals];
 DWORD nFaceNormals;
 array MeshFace faceNormals[nFaceNormals];
}

template MeshVertexColors {
 <1630B821-7842-11cf-8F52-0040333594A3>
 DWORD nVertexColors;
 array IndexedColor vertexColors[nVertexColors];
}

template Mesh {
 <3D82AB44-62DA-11cf-AB39-0020AF71E433>
 DWORD nVertices;
 array Vector vertices[nVertices];
 DWORD nFaces;
 array MeshFace faces[nFaces];
 [...]
}

template FrameTransformMatrix {
 <F6F23F41-7686-11cf-8F52-0040333594A3>
 Matrix4x4 frameMatrix;
}

template Frame {
 <3D82AB46-62DA-11cf-AB39-0020AF71E433>
 [...]
}

Header {
 1;
 0;
 1;
}



Mesh CINEMA4D_Mesh {
  16;
  // Lever1
  4.968;-3.861;6.175;,
  44.767;43.898;-0.249;,
  -4.623;4.154;6.346;,
  35.177;51.913;-0.078;,
  -5.577;3.277;-6.087;,
  34.222;51.036;-12.511;,
  4.014;-4.738;-6.258;,
  43.813;43.021;-12.682;,
  // Lever_Hold
  -25.0;-9.375;-18.75;,
  -25.0;9.375;-18.75;,
  25.0;-9.375;-18.75;,
  25.0;9.375;-18.75;,
  25.0;-9.375;18.75;,
  25.0;9.375;18.75;,
  -25.0;-9.375;18.75;,
  -25.0;9.375;18.75;;
  
  12;
  // Lever1
  4;0,1,3,2;,
  4;2,3,5,4;,
  4;4,5,7,6;,
  4;6,7,1,0;,
  4;1,7,5,3;,
  4;6,0,2,4;,
  // Lever_Hold
  4;8,9,11,10;,
  4;10,11,13,12;,
  4;12,13,15,14;,
  4;14,15,9,8;,
  4;9,15,13,11;,
  4;14,8,10,12;;
  
  MeshNormals {
    16;
    // Lever1
    -0.084;-0.158;0.054;,
    0.145;0.117;0.017;,
    -0.14;-0.112;0.055;,
    0.09;0.164;0.018;,
    -0.145;-0.117;-0.017;,
    0.084;0.158;-0.054;,
    -0.09;-0.164;-0.018;,
    0.14;0.112;-0.055;,
    // Lever_Hold
    -0.144;-0.054;-0.108;,
    -0.144;0.054;-0.108;,
    0.144;-0.054;-0.108;,
    0.144;0.054;-0.108;,
    0.144;-0.054;0.108;,
    0.144;0.054;0.108;,
    -0.144;-0.054;0.108;,
    -0.144;0.054;0.108;;
    
    12;
    // Lever1
    4;0,1,3,2;,
    4;2,3,5,4;,
    4;4,5,7,6;,
    4;6,7,1,0;,
    4;1,7,5,3;,
    4;6,0,2,4;,
    // Lever_Hold
    4;8,9,11,10;,
    4;10,11,13,12;,
    4;12,13,15,14;,
    4;14,15,9,8;,
    4;9,15,13,11;,
    4;14,8,10,12;;
    
  }
  MeshTextureCoords {
    16;
    // Lever1
    0.027;0.399;,
    0.027;0.437;,
    0.035;0.399;,
    0.035;0.437;,
    0.035;0.437;,
    0.035;0.399;,
    0.027;0.437;,
    0.027;0.399;,
    // Lever_Hold
    0.0;0.063;,
    0.0;0.086;,
    0.031;0.063;,
    0.031;0.086;,
    0.031;0.086;,
    0.031;0.063;,
    0.0;0.086;,
    0.0;0.063;;
  }
  MeshMaterialList {
    2;
    12;
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1;
    
    Material C4DMAT_NONE {
      1.0;1.0;1.0;1.0;;
      1.0;
      0.0;0.0;0.0;;
      0.0;0.0;0.0;;
    }
    Material C4DMAT_Terrain {
      1.0;1.0;1.0;1.0;;
      1.0;
      0.0;0.0;0.0;;
      0.0;0.0;0.0;;
    }
    
  }
}