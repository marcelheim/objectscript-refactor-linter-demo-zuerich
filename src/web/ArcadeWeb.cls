Class arcade.ArcadeWeb Extends %CSP.Page
{

Parameter CONTENTTYPE = "text/html";

ClassMethod OnPage() As %Status
{
    Set action = %request.Get("action")
    If action = "top"    { Quit ..LbTop() }
    If action = "submit" { Quit ..LbSubmit() }
    Do ..ServeHTML()
    Quit $$$OK
}

ClassMethod LbTop() As %Status
{
    Set %response.ContentType = "application/json"
    Set rows = $$Top^arcade.score.Board("INVADERS^10")
    Write "{""rows"":"""_rows_"""}"
    Quit $$$OK
}

ClassMethod LbSubmit() As %Status
{
    Set %response.ContentType = "application/json"
    Set player = %request.Get("player")
    Set score  = +%request.Get("score")
    Set result = $$Submit^arcade.score.Board("INVADERS^" _ player _ "^" _ score)
    Write "{""result"":"""_result_"""}"
    Quit $$$OK
}

ClassMethod ServeHTML() As %Status
{
    Write "<!DOCTYPE html>",!
    Write "<html lang='en'>",!
    Write "<head>",!
    Write "<meta charset='UTF-8'>",!
    Write "<meta name='viewport' content='width=device-width, initial-scale=1'>",!
    Write "<title>IRIS ARCADE // SPACE INVADERS</title>",!
    Write "<style>",!
    Write "  * { margin:0; padding:0; box-sizing:border-box; }",!
    Write "  body { background:#140d00; color:#ffb000; font-family:'Courier New',monospace;",!
    Write "         display:flex; flex-direction:column; align-items:center; min-height:100vh;",!
    Write "         padding:1.2rem; gap:1rem; }",!
    Write "  h1 { font-size:1.4rem; letter-spacing:0.4em; text-shadow:0 0 12px #ff8c00; }",!
    Write "  #sub { font-size:0.58rem; letter-spacing:0.25em; color:#7a4a00; }",!
    Write "  .wrap { display:flex; gap:1.6rem; align-items:flex-start; flex-wrap:wrap; justify-content:center; }",!
    Write "  .stage { position:relative; }",!
    Write "  canvas { background:#0a0600; border:1px solid #4a3000; display:block; }",!
    Write "  .hud { display:flex; justify-content:space-between; font-size:0.7rem;",!
    Write "         letter-spacing:0.15em; padding:0.4rem 0.2rem; }",!
    Write "  .overlay { position:absolute; inset:0; display:flex; flex-direction:column;",!
    Write "             align-items:center; justify-content:center; gap:0.8rem;",!
    Write "             background:rgba(10,6,0,0.86); text-align:center; }",!
    Write "  .overlay.hidden { display:none; }",!
    Write "  .overlay .big { font-size:1.3rem; letter-spacing:0.3em; text-shadow:0 0 10px #ff8c00; }",!
    Write "  .overlay .small { font-size:0.7rem; letter-spacing:0.2em; color:#ffd47a; }",!
    Write "  .blink { animation:bl 1s steps(2) infinite; }",!
    Write "  @keyframes bl { 50% { opacity:0.25; } }",!
    Write "  input { background:#0a0600; border:1px solid #ffb000; color:#ffb000;",!
    Write "          font-family:'Courier New',monospace; font-size:1.1rem; width:120px;",!
    Write "          text-align:center; letter-spacing:0.4em; padding:0.4rem; text-transform:uppercase; outline:none; }",!
    Write "  button { background:none; border:1px solid #ffb000; color:#ffb000;",!
    Write "           font-family:'Courier New',monospace; font-size:0.75rem; letter-spacing:0.2em;",!
    Write "           padding:0.45rem 1.3rem; cursor:pointer; transition:background 0.15s,color 0.15s; }",!
    Write "  button:hover { background:#ffb000; color:#140d00; }",!
    Write "  .board { border:1px solid #4a3000; min-width:300px; }",!
    Write "  .board .ttl { font-size:0.6rem; letter-spacing:0.25em; color:#7a4a00; padding:0.6rem 1rem; border-bottom:1px solid #2a1c00; }",!
    Write "  .row { display:grid; grid-template-columns:40px 1fr 90px; padding:0.4rem 1rem;",!
    Write "         font-size:0.85rem; letter-spacing:0.1em; border-bottom:1px solid #2a1c00; }",!
    Write "  .row .sc { text-align:right; }",!
    Write "  .row.r1 { color:#fff2cc; text-shadow:0 0 10px #ffcc00; }",!
    Write "  .row.r2 { color:#ffd47a; } .row.r3 { color:#ffb000; }",!
    Write "  .empty { padding:1.2rem; text-align:center; color:#7a4a00; font-size:0.7rem; }",!
    Write "</style>",!
    Write "</head>",!
    Write "<body>",!
    Write "  <h1>IRIS ARCADE</h1>",!
    Write "  <div id='sub'>SPACE INVADERS // SCORES PERSISTED IN OBJECTSCRIPT ON IRIS</div>",!
    Write "  <div class='wrap'>",!
    Write "    <div>",!
    Write "      <div class='hud'><span>SCORE <span id='score'>0</span></span>",!
    Write "        <span>WAVE <span id='wave'>1</span></span><span>LIVES <span id='lives'>3</span></span></div>",!
    Write "      <div class='stage'>",!
    Write "        <canvas id='game' width='460' height='520'></canvas>",!
    Write "        <div class='overlay' id='ov'>",!
    Write "          <div class='big' id='ovbig'>SPACE INVADERS</div>",!
    Write "          <div class='small' id='ovsmall'>&larr; &rarr; MOVE &nbsp; SPACE FIRE</div>",!
    Write "          <div id='ovform'></div>",!
    Write "          <div class='small blink' id='ovhint'>[ PRESS ENTER TO START ]</div>",!
    Write "        </div>",!
    Write "      </div>",!
    Write "    </div>",!
    Write "    <div class='board'>",!
    Write "      <div class='ttl'>HIGH SCORES</div>",!
    Write "      <div id='rows'></div>",!
    Write "    </div>",!
    Write "  </div>",!
    Write "<script>",!
    Write "const cv=document.getElementById('game'),x=cv.getContext('2d');",!
    Write "const W=cv.width,H=cv.height;",!
    Write "const ALIEN=['00100000100','00010001000','00111111100','01101110110','11111111111','10111111101','10100000101','00011011000'];",!
    Write "let state='start',score=0,lives=3,wave=1;",!
    Write "let player,bullets=[],bombs=[],inv,shields=[],dir,stepMs,lastStep,frame=0,cool=0;",!
    Write "const keys={};",!
    Write "function reset(){score=0;lives=3;wave=1;player={x:W/2-15,y:H-40,w:30,h:14,sp:5};bullets=[];bombs=[];spawn();state='play';sync();}",!
    Write "function spawn(){inv=[];const cols=8,rows=5,gx=46,gy=34,ox=40,oy=60;",!
    Write "  for(let r=0;r<rows;r++)for(let c=0;c<cols;c++)inv.push({x:ox+c*gx,y:oy+r*gy,w:22,h:16,row:r,alive:true});",!
    Write "  dir=1;stepMs=Math.max(200,700-wave*60);lastStep=0;frame=0;cool=0;buildShields();}",!
    Write "function buildShields(){shields=[];const n=4,bw=7,bh=5,bs=6,by=player.y-72;",!
    Write "  const span=n*bw*bs,gap=(W-span)/(n+1);",!
    Write "  for(let i=0;i<n;i++){const bx=gap+i*(bw*bs+gap);",!
    Write "    for(let r=0;r<bh;r++)for(let c=0;c<bw;c++){",!
    Write "      if(r>=bh-2&&c>=2&&c<=4)continue;",!
    Write "      shields.push({x:bx+c*bs,y:by+r*bs,w:bs,h:bs});}}}",!
    Write "function alive(){return inv.filter(a=>a.alive);}",!
    Write "document.addEventListener('keydown',e=>{keys[e.code]=true;",!
    Write "  if(['ArrowLeft','ArrowRight','Space'].includes(e.code))e.preventDefault();",!
    Write "  if(e.code==='Enter'){if(state==='start')reset();else if(state==='over')doSubmit();}});",!
    Write "document.addEventListener('keyup',e=>{keys[e.code]=false;});",!
    Write "function update(t){",!
    Write "  if(keys['ArrowLeft'])player.x-=player.sp;",!
    Write "  if(keys['ArrowRight'])player.x+=player.sp;",!
    Write "  player.x=Math.max(6,Math.min(W-player.w-6,player.x));",!
    Write "  if(cool>0)cool--;",!
    Write "  if(keys['Space']&&cool===0){bullets.push({x:player.x+player.w/2-1.5,y:player.y,w:3,h:10});cool=14;}",!
    Write "  bullets.forEach(b=>b.y-=8); bullets=bullets.filter(b=>b.y>-10);",!
    Write "  const live=alive();",!
    Write "  if(t-lastStep>stepMs){lastStep=t;frame^=1;",!
    Write "    let minx=1e9,maxx=-1e9; live.forEach(a=>{minx=Math.min(minx,a.x);maxx=Math.max(maxx,a.x+a.w);});",!
    Write "    if((maxx+12*dir>W-6)||(minx+12*dir<6)){dir*=-1;live.forEach(a=>a.y+=16);}",!
    Write "    else live.forEach(a=>a.x+=12*dir);",!
    Write "    if(live.length&&Math.random()<0.4){const s=live[Math.floor(Math.random()*live.length)];",!
    Write "      bombs.push({x:s.x+s.w/2,y:s.y+s.h,w:3,h:10});}}",!
    Write "  bombs.forEach(b=>b.y+=3); bombs=bombs.filter(b=>b.y<H+10);",!
    Write "  bullets.forEach(b=>{live.forEach(a=>{if(a.alive&&hit(b,a)){a.alive=false;b.y=-99;",!
    Write "    score+=(5-a.row)*10;sync();}});});",!
    Write "  bullets=bullets.filter(b=>b.y>-10);",!
    Write "  bombs.forEach(b=>{if(hit(b,player)){b.y=H+99;loseLife();}});",!
    Write "  bombs=bombs.filter(b=>b.y<H+10);",!
    Write "  bullets.forEach(b=>{shields.forEach(s=>{if(!s.dead&&hit(b,s)){s.dead=1;b.y=-99;}});});",!
    Write "  bombs.forEach(b=>{shields.forEach(s=>{if(!s.dead&&hit(b,s)){s.dead=1;b.y=H+99;}});});",!
    Write "  live.forEach(a=>{shields.forEach(s=>{if(!s.dead&&hit(a,s))s.dead=1;});});",!
    Write "  shields=shields.filter(s=>!s.dead);bullets=bullets.filter(b=>b.y>-10);bombs=bombs.filter(b=>b.y<H+10);",!
    Write "  if(live.some(a=>a.y+a.h>=player.y)){lives=0;sync();gameOver();return;}",!
    Write "  if(alive().length===0){wave++;spawn();sync();}",!
    Write "}",!
    Write "function hit(b,a){return b.x<a.x+a.w&&b.x+b.w>a.x&&b.y<a.y+a.h&&b.y+b.h>a.y;}",!
    Write "function loseLife(){lives--;sync();if(lives<=0)gameOver();}",!
    Write "function gameOver(){state='over';showForm();}",!
    Write "function drawAlien(a){x.fillStyle=(a.row<1)?'#ff4e00':(a.row<3?'#ffb000':'#ffd47a');",!
    Write "  const px=2;for(let r=0;r<8;r++){const rowdef=ALIEN[(r+frame)%8];",!
    Write "    for(let c=0;c<11;c++)if(rowdef[c]==='1')x.fillRect(a.x+c*px,a.y+r*px,px,px);}}",!
    Write "function draw(){x.clearRect(0,0,W,H);",!
    Write "  if(inv)alive().forEach(drawAlien);",!
    Write "  x.fillStyle='#5a8a2a';shields.forEach(s=>x.fillRect(s.x,s.y,s.w,s.h));",!
    Write "  if(player){x.fillStyle='#ffb000';x.fillRect(player.x,player.y+6,player.w,8);",!
    Write "    x.fillRect(player.x+player.w/2-2,player.y,4,8);}",!
    Write "  x.fillStyle='#fff2cc';bullets.forEach(b=>x.fillRect(b.x,b.y,b.w,b.h));",!
    Write "  x.fillStyle='#ff4e00';bombs.forEach(b=>x.fillRect(b.x,b.y,b.w,b.h));}",!
    Write "function loop(t){if(state==='play')update(t);draw();requestAnimationFrame(loop);}",!
    Write "function sync(){document.getElementById('score').textContent=score;",!
    Write "  document.getElementById('wave').textContent=wave;",!
    Write "  document.getElementById('lives').textContent=Math.max(0,lives);}",!
    Write "const ov=document.getElementById('ov');",!
    Write "function showOverlay(big,small,hint){document.getElementById('ovbig').textContent=big;",!
    Write "  document.getElementById('ovsmall').innerHTML=small;",!
    Write "  document.getElementById('ovform').innerHTML='';",!
    Write "  document.getElementById('ovhint').innerHTML=hint;ov.classList.remove('hidden');}",!
    Write "function hideOverlay(){ov.classList.add('hidden');}",!
    Write "function startLoop(){hideOverlay();}",!
    Write "function showForm(){",!
    Write "  document.getElementById('ovbig').textContent='GAME OVER';",!
    Write "  document.getElementById('ovsmall').textContent='SCORE '+score;",!
    Write "  document.getElementById('ovform').innerHTML=",!
    Write "    '<input id=\""ini\"" maxlength=\""3\"" placeholder=\""AAA\"" autocomplete=\""off\"">';",!
    Write "  document.getElementById('ovhint').innerHTML='[ ENTER TO SAVE SCORE ]';",!
    Write "  ov.classList.remove('hidden');",!
    Write "  document.getElementById('ini').focus();",!
    Write "}",!
    Write "async function doSubmit(){",!
    Write "  const el=document.getElementById('ini');",!
    Write "  let p=(el?el.value:'').trim().toUpperCase()||'AAA';",!
    Write "  await fetch('?action=submit&player='+encodeURIComponent(p)+'&score='+score);",!
    Write "  await loadBoard();",!
    Write "  state='start';",!
    Write "  showOverlay('SPACE INVADERS','&larr; &rarr; MOVE &nbsp; SPACE FIRE','[ PRESS ENTER TO START ]');",!
    Write "}",!
    Write "async function loadBoard(){",!
    Write "  const d=await(await fetch('?action=top')).json();",!
    Write "  const box=document.getElementById('rows');box.innerHTML='';",!
    Write "  if(!d.rows){box.innerHTML='<div class=\""empty\"">NO SCORES YET</div>';return;}",!
    Write "  d.rows.split('|').forEach(r=>{const p=r.split('^');const row=document.createElement('div');",!
    Write "    row.className='row'+(p[0]<=3?(' r'+p[0]):'');",!
    Write "    row.innerHTML='<div>'+p[0]+'</div><div>'+esc(p[1])+'</div><div class=\""sc\"">'+p[2]+'</div>';",!
    Write "    box.appendChild(row);});}",!
    Write "function esc(s){const d=document.createElement('div');d.textContent=s;return d.innerHTML;}",!
    Write "const _start=reset;reset=function(){startLoop();_start();};",!
    Write "loadBoard();requestAnimationFrame(loop);",!
    Write "</script>",!
    Write "</body>",!
    Write "</html>",!
    Quit $$$OK
}

}
