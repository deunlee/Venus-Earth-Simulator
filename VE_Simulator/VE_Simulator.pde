// Venus-Earth Retrograde Motion Simulator
// Author  : Deun Lee
// Version : 1.8.2
// License : MIT

int Radius;

// Sun, Venus, Earth (a = angle), Venus CS
float Sx, Sy, Va, Vx, Vy, Ea, Ex, Ey, VCSx, VCSy, VCSdDelta;

// Venus CS Diameter
int VCSdMax, VCSdMin;

float DiameterCS, DiameterSun;
float AngleVenus = 180.0, AngleEarth = 0.0;

float DiameterVenus = 0.948843; // 12,103.7   km
float DiameterEarth = 1.0;      // 12,756.270 km

float LineVenus = 0.723331; // 0.723331 AU (Long Diameter)
float LineEarth = 1.0;      // 1.000000 AU

float RevolveSpeedVenus = 1.6; // 1.598571; // 35,020 km/s -> 4.545 AU (7705.170517)
float RevolveSpeedEarth = 1.0;              // 29,783 km/s -> 6.179 AU (4820.035604)

float RMLastPos = 0.0; // Retrograde Motion
int RMLastColor = 1;

float[] AIx = new float[20]; // Afterimage Array
float[] AIy = new float[20];
int[] AIc = new int[20]; // Color
int AIcnt = 0, AIpos = 0; 

int AutoPlay = 1; // 0 = Manual, 1 = Auto

void setup()
{
  size(600, 400);
  textSize(14);
  
  Radius = min(width, height) / 2;

  Sx = width / 2 - 100;
  Sy = height / 2 + 10;

  DiameterCS = Radius * 1.75;
  DiameterSun = Radius * 0.2;

  DiameterVenus *= Radius * 0.1;
  DiameterEarth *= Radius * 0.1;

  LineVenus *= Radius * 0.6;
  LineEarth *= Radius * 0.6;

  VCSdMax = round(Square(LineEarth + LineVenus + 1));
  VCSdMin = round(Square(LineEarth - LineVenus - 1));

  for (int i = 0; i < AIx.length; i ++)
  {
    AIx[i] = 0.0;
    AIy[i] = 0.0;
  }

  DrawSolarSystem(0);
}

void draw()
{
  if (AutoPlay == 1)
  {
    DrawSolarSystem(1);
    delay(20);
  }
}

void DrawSolarSystem(float Speed)
{
  background(0);
  fill(80); 
  noStroke();
  ellipse(Sx, Sy, DiameterCS, DiameterCS);

  AngleVenus -= RevolveSpeedVenus * Speed;
  if (AngleVenus >= 360)
    AngleVenus -= 360;
  else if (AngleVenus < 0)
    AngleVenus += 360;

  AngleEarth -= RevolveSpeedEarth * Speed;
  if (AngleEarth >= 360)
    AngleEarth -= 360;
  else if (AngleEarth < 0)
    AngleEarth += 360;

  ////////////////////////////////////////////////////////////

  Va = map(AngleVenus, 0, 360, 0, TWO_PI) - HALF_PI;
  Vx = Sx + cos(Va) * LineVenus;
  Vy = Sy + sin(Va) * LineVenus;
  stroke(200, 200, 50); 
  strokeWeight(1.5);
  line(Sx, Sy, Vx, Vy);

  Ea = map(AngleEarth, 0, 360, 0, TWO_PI) - HALF_PI;
  Ex = Sx + cos(Ea) * LineEarth;
  Ey = Sy + sin(Ea) * LineEarth;
  stroke(100, 200, 255); 
  strokeWeight(1.5);
  line(Sx, Sy, Ex, Ey);

  CalculateCSVenusPos();

  if (abs(Sx - VCSx) > 0.000001)
  {
    if (abs(RMLastPos - (Sx - VCSy) / (Sx - VCSx)) < 10)
    {
      if (RMLastPos >= (Sx - VCSy) / (Sx - VCSx))
        RMLastColor = 0; // CCW
      else
        RMLastColor = 1; // CW
    }

    RMLastPos = (Sx - VCSy) / (Sx - VCSx);
  }

  if (Speed != 0)
  {
    if (++AIcnt == 5)
    {
      AIcnt = 0;

      AIx[AIpos] = VCSx;
      AIy[AIpos] = VCSy;
      AIc[AIpos] = RMLastColor;

      if (++AIpos == AIx.length)
        AIpos = 0;
    }
  }

  ////////////////////////////////////////////////////////////

  noStroke();

  for (int i = 0; i < AIx.length; i ++)
  {
    if (AIx[i] != 0.0)
    {
      if (AIc[i] == 0)
        fill(0, 230, 0, 180); // CCW - Green
      else
        fill(230, 0, 0, 180); // CW - Red

      ellipse(AIx[i], AIy[i], DiameterVenus / 2, DiameterVenus / 2);
    }
  }

  noFill(); 
  stroke(255); 
  strokeWeight(1.3);
  ellipse(Sx, Sy, LineVenus * 2, LineVenus * 2);
  ellipse(Sx, Sy, LineEarth * 2, LineEarth * 2);

  fill(255, 255, 40); 
  noStroke();
  ellipse(Sx, Sy, DiameterSun, DiameterSun);

  fill(255, 0, 0);
  text("Sun", Sx - 12, Sy + 4);

  stroke(0); 
  strokeWeight(3);
  line(Ex, Ey, VCSx, VCSy);

  fill(40, 100, 255); 
  noStroke();
  ellipse(Ex, Ey, DiameterEarth, DiameterEarth);

  fill(180, 130, 30);
  ellipse(Vx, Vy, DiameterVenus, DiameterVenus);

  if (RMLastColor == 0)
    fill(80, 255, 80); // CCW - Green
  else
    fill(255, 80, 80); // CW - Red

  VCSdDelta = map(DistanceSquare(Vx, Vy, Ex, Ey), VCSdMin, VCSdMax, 8, -3);
  ellipse(VCSx, VCSy, DiameterVenus + VCSdDelta, DiameterVenus + VCSdDelta);

  ////////////////////////////////////////////////////////////

  fill(0);
  text("V", Vx - 4,   Vy + 4);
  text("E", Ex - 4,   Ey + 4);
  text("V", VCSx - 4, VCSy + 4);

  ////////////////////////////////////////////////////////////

  fill(255);
  text("< Venus-Earth Retrograde Motion Simulator by Deun Lee > (V.1.8.2)", 15, 20);
  
  int TextX = 400, TextY = 50;
  text("===============",                                  TextX, TextY);
  text("* Venus Angle : " + round(AngleVenus) + "'",       TextX, TextY += 20);
  text("* Earth Angle : " + round(AngleEarth) + "'",       TextX, TextY += 20);
  text("===============",                                  TextX, TextY += 20);
  text("* Venus Speed : " + round(RevolveSpeedVenus * 10), TextX, TextY += 20);
  text("* Earth Speed : " + round(RevolveSpeedEarth * 10), TextX, TextY += 20);
  text("===============",                                  TextX, TextY += 20);

  if (AutoPlay == 1)
  {
    fill(255);
    text("< Auto Mode >",               TextX, TextY = 300);
    text("  7(+) & 8(-) : Venus Speed", TextX, TextY += 20);
    text("  9(+) & 0(-) : Earth Speed", TextX, TextY += 20);
    text("===============",             TextX, TextY += 20);
    text("  M : Manual Mode",           TextX, TextY += 20);
  }
  else
  {
    text("< Manual Mode >",             TextX, TextY = 220);
    text("  1(CCW) & 2(CW) : Slow",     TextX, TextY += 20);
    text("  3(CCW) & 4(CW) : Normal",   TextX, TextY += 20);
    text("  5(CCW) & 6(CW) : Fast",     TextX, TextY += 20);
    text("===============",             TextX, TextY += 20);
    text("  7(+) & 8(-) : Venus Speed", TextX, TextY += 20);
    text("  9(+) & 0(-) : Earth Speed", TextX, TextY += 20);
    text("===============",             TextX, TextY += 20);
    text("  A : Auto Mode",             TextX, TextY += 20);
  }
}

void keyPressed()
{
  if (key == '7')
    SetSpeed(0.1, 0.0);
  else if (key == '8')
    SetSpeed(-0.1, 0.0);
  else if (key == '9')
    SetSpeed(0.0, 0.1);
  else if (key == '0')
    SetSpeed(0.0, -0.1);
  else if (AutoPlay == 0)
  {
    if (key == '1' || key == ' ')
      DrawSolarSystem(0.5);
    else if (key == '2')
      DrawSolarSystem(-0.5);
    else if (key == '3')
      DrawSolarSystem(1);
    else if (key == '4')
      DrawSolarSystem(-1);
    else if (key == '5')
      DrawSolarSystem(2);
    else if (key == '6')
      DrawSolarSystem(-2);
    else if (key == 'A' || key == 'a')
      AutoPlay = 1;
    else
      DrawSolarSystem(0);
  }
  else 
  {
    if (key == 'M' || key == 'm')
    {
      AutoPlay = 0;
      DrawSolarSystem(0);
    }
  }
}

void SetSpeed(float DeltaVenus, float DeltaEarth)
{
  RevolveSpeedVenus += DeltaVenus;
  RevolveSpeedEarth += DeltaEarth;

  if (RevolveSpeedVenus > 3.0) 
    RevolveSpeedVenus = 3.0;
  else if (RevolveSpeedVenus < 0.1)
    RevolveSpeedVenus = 0.1;

  if (RevolveSpeedEarth > 3.0) 
    RevolveSpeedEarth = 3.0;
  else if (RevolveSpeedEarth < 0.1)
    RevolveSpeedEarth = 0.1;

  DrawSolarSystem(0);
}

void CalculateCSVenusPos()
{
  double a, b, x1, x2, CSa, CSb, CSc;

  if (abs(Vx - Ex) > 0.000001) // Vx - Ex != 0
  {
    a = (Vy - Ey) / (Vx - Ex);
    b = (-1) * a * Vx + Vy;

    CSa = a * a + 1;
    CSb = a * b - Sx - a * Sy;
    CSc = Sx * Sx + Sy * Sy + b * b - Square(DiameterCS / 2) - 2 * b * Sy;

    x1 = sqrt((float)(CSb * CSb - CSa * CSc));
    x2 = ((-1) * CSb + x1) / CSa;
    x1 = ((-1) * CSb - x1) / CSa;

    CSa = a * x1 + b; // CSa <- y1
    CSb = DistanceSquareD(Vx, Vy, x1, CSa);
    CSc = DistanceSquareD(Ex, Ey, x1, CSa);

    if (CSb < CSc)
    {
      VCSx = (float)x1;
      VCSy = (float)(a * x1 + b);
    } else
    {
      VCSx = (float)x2;
      VCSy = (float)(a * x2 + b);
    }
  } else
  {
    VCSx = Sx;
    CSb = DistanceSquare(Vx, Vy, VCSx, Sy + DiameterCS / 2);
    CSc = DistanceSquare(Ex, Ey, VCSx, Sy + DiameterCS / 2);

    if (CSb < CSc)
      VCSy = Sy + DiameterCS / 2;
    else
      VCSy = Sy - DiameterCS / 2;
  }
}

float Square(float n)
{
  return n * n;
}

float DistanceSquare(float x1, float y1, float x2, float y2)
{
  return Square(x1 - x2) + Square(y1 - y2);
}

double SquareD(double n)
{
  return n * n;
}

double DistanceSquareD(double x1, double y1, double x2, double y2)
{
  return SquareD(x1 - x2) + SquareD(y1 - y2);
}

float Distance(float x1, float y1, float x2, float y2)
{
  return sqrt(DistanceSquare(x1, y1, x2, y2));
}
