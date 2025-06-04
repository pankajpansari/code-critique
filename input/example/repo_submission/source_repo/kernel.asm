
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 30 a8 15 88       	mov    $0x8815a830,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 30 30 10 80       	mov    $0x80103030,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	53                   	push   %ebx

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100044:	bb 14 26 15 88       	mov    $0x88152614,%ebx
{
80100049:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
8010004c:	68 60 6f 10 80       	push   $0x80106f60
80100051:	68 e0 25 15 88       	push   $0x881525e0
80100056:	e8 e5 42 00 00       	call   80104340 <initlock>
  bcache.head.next = &bcache.head;
8010005b:	83 c4 10             	add    $0x10,%esp
8010005e:	b8 dc 6c 15 88       	mov    $0x88156cdc,%eax
  bcache.head.prev = &bcache.head;
80100063:	c7 05 2c 6d 15 88 dc 	movl   $0x88156cdc,0x88156d2c
8010006a:	6c 15 88 
  bcache.head.next = &bcache.head;
8010006d:	c7 05 30 6d 15 88 dc 	movl   $0x88156cdc,0x88156d30
80100074:	6c 15 88 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100077:	eb 09                	jmp    80100082 <binit+0x42>
80100079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100080:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100082:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
80100085:	83 ec 08             	sub    $0x8,%esp
80100088:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010008b:	c7 43 50 dc 6c 15 88 	movl   $0x88156cdc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100092:	68 67 6f 10 80       	push   $0x80106f67
80100097:	50                   	push   %eax
80100098:	e8 73 41 00 00       	call   80104210 <initsleeplock>
    bcache.head.next->prev = b;
8010009d:	a1 30 6d 15 88       	mov    0x88156d30,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a2:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
801000a8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000ab:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
801000ae:	89 d8                	mov    %ebx,%eax
801000b0:	89 1d 30 6d 15 88    	mov    %ebx,0x88156d30
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b6:	81 fb 80 6a 15 88    	cmp    $0x88156a80,%ebx
801000bc:	75 c2                	jne    80100080 <binit+0x40>
  }
}
801000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801000c1:	c9                   	leave
801000c2:	c3                   	ret
801000c3:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801000ca:	00 
801000cb:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

801000d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000d0:	55                   	push   %ebp
801000d1:	89 e5                	mov    %esp,%ebp
801000d3:	57                   	push   %edi
801000d4:	56                   	push   %esi
801000d5:	53                   	push   %ebx
801000d6:	83 ec 18             	sub    $0x18,%esp
801000d9:	8b 75 08             	mov    0x8(%ebp),%esi
801000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  acquire(&bcache.lock);
801000df:	68 e0 25 15 88       	push   $0x881525e0
801000e4:	e8 b7 43 00 00       	call   801044a0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000e9:	8b 1d 30 6d 15 88    	mov    0x88156d30,%ebx
801000ef:	83 c4 10             	add    $0x10,%esp
801000f2:	81 fb dc 6c 15 88    	cmp    $0x88156cdc,%ebx
801000f8:	75 11                	jne    8010010b <bread+0x3b>
801000fa:	eb 24                	jmp    80100120 <bread+0x50>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100100:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100103:	81 fb dc 6c 15 88    	cmp    $0x88156cdc,%ebx
80100109:	74 15                	je     80100120 <bread+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010010b:	3b 73 04             	cmp    0x4(%ebx),%esi
8010010e:	75 f0                	jne    80100100 <bread+0x30>
80100110:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100113:	75 eb                	jne    80100100 <bread+0x30>
      b->refcnt++;
80100115:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100119:	eb 3f                	jmp    8010015a <bread+0x8a>
8010011b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100120:	8b 1d 2c 6d 15 88    	mov    0x88156d2c,%ebx
80100126:	81 fb dc 6c 15 88    	cmp    $0x88156cdc,%ebx
8010012c:	75 0d                	jne    8010013b <bread+0x6b>
8010012e:	eb 6e                	jmp    8010019e <bread+0xce>
80100130:	8b 5b 50             	mov    0x50(%ebx),%ebx
80100133:	81 fb dc 6c 15 88    	cmp    $0x88156cdc,%ebx
80100139:	74 63                	je     8010019e <bread+0xce>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010013e:	85 c0                	test   %eax,%eax
80100140:	75 ee                	jne    80100130 <bread+0x60>
80100142:	f6 03 04             	testb  $0x4,(%ebx)
80100145:	75 e9                	jne    80100130 <bread+0x60>
      b->dev = dev;
80100147:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
8010014a:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
8010014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
80100153:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
8010015a:	83 ec 0c             	sub    $0xc,%esp
8010015d:	68 e0 25 15 88       	push   $0x881525e0
80100162:	e8 f9 43 00 00       	call   80104560 <release>
      acquiresleep(&b->lock);
80100167:	8d 43 0c             	lea    0xc(%ebx),%eax
8010016a:	89 04 24             	mov    %eax,(%esp)
8010016d:	e8 de 40 00 00       	call   80104250 <acquiresleep>
      return b;
80100172:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
80100175:	f6 03 02             	testb  $0x2,(%ebx)
80100178:	74 0e                	je     80100188 <bread+0xb8>
    iderw(b);
  }
  return b;
}
8010017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010017d:	89 d8                	mov    %ebx,%eax
8010017f:	5b                   	pop    %ebx
80100180:	5e                   	pop    %esi
80100181:	5f                   	pop    %edi
80100182:	5d                   	pop    %ebp
80100183:	c3                   	ret
80100184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    iderw(b);
80100188:	83 ec 0c             	sub    $0xc,%esp
8010018b:	53                   	push   %ebx
8010018c:	e8 3f 21 00 00       	call   801022d0 <iderw>
80100191:	83 c4 10             	add    $0x10,%esp
}
80100194:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100197:	89 d8                	mov    %ebx,%eax
80100199:	5b                   	pop    %ebx
8010019a:	5e                   	pop    %esi
8010019b:	5f                   	pop    %edi
8010019c:	5d                   	pop    %ebp
8010019d:	c3                   	ret
  panic("bget: no buffers");
8010019e:	83 ec 0c             	sub    $0xc,%esp
801001a1:	68 6e 6f 10 80       	push   $0x80106f6e
801001a6:	e8 d5 01 00 00       	call   80100380 <panic>
801001ab:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

801001b0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001b0:	55                   	push   %ebp
801001b1:	89 e5                	mov    %esp,%ebp
801001b3:	53                   	push   %ebx
801001b4:	83 ec 10             	sub    $0x10,%esp
801001b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001ba:	8d 43 0c             	lea    0xc(%ebx),%eax
801001bd:	50                   	push   %eax
801001be:	e8 2d 41 00 00       	call   801042f0 <holdingsleep>
801001c3:	83 c4 10             	add    $0x10,%esp
801001c6:	85 c0                	test   %eax,%eax
801001c8:	74 0f                	je     801001d9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ca:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001cd:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001d3:	c9                   	leave
  iderw(b);
801001d4:	e9 f7 20 00 00       	jmp    801022d0 <iderw>
    panic("bwrite");
801001d9:	83 ec 0c             	sub    $0xc,%esp
801001dc:	68 7f 6f 10 80       	push   $0x80106f7f
801001e1:	e8 9a 01 00 00       	call   80100380 <panic>
801001e6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801001ed:	00 
801001ee:	66 90                	xchg   %ax,%ax

801001f0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	56                   	push   %esi
801001f4:	53                   	push   %ebx
801001f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001f8:	8d 73 0c             	lea    0xc(%ebx),%esi
801001fb:	83 ec 0c             	sub    $0xc,%esp
801001fe:	56                   	push   %esi
801001ff:	e8 ec 40 00 00       	call   801042f0 <holdingsleep>
80100204:	83 c4 10             	add    $0x10,%esp
80100207:	85 c0                	test   %eax,%eax
80100209:	74 63                	je     8010026e <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
8010020b:	83 ec 0c             	sub    $0xc,%esp
8010020e:	56                   	push   %esi
8010020f:	e8 9c 40 00 00       	call   801042b0 <releasesleep>

  acquire(&bcache.lock);
80100214:	c7 04 24 e0 25 15 88 	movl   $0x881525e0,(%esp)
8010021b:	e8 80 42 00 00       	call   801044a0 <acquire>
  b->refcnt--;
80100220:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100223:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
80100226:	83 e8 01             	sub    $0x1,%eax
80100229:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010022c:	85 c0                	test   %eax,%eax
8010022e:	75 2c                	jne    8010025c <brelse+0x6c>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100230:	8b 53 54             	mov    0x54(%ebx),%edx
80100233:	8b 43 50             	mov    0x50(%ebx),%eax
80100236:	89 42 50             	mov    %eax,0x50(%edx)
    b->prev->next = b->next;
80100239:	8b 53 54             	mov    0x54(%ebx),%edx
8010023c:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
8010023f:	a1 30 6d 15 88       	mov    0x88156d30,%eax
    b->prev = &bcache.head;
80100244:	c7 43 50 dc 6c 15 88 	movl   $0x88156cdc,0x50(%ebx)
    b->next = bcache.head.next;
8010024b:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
8010024e:	a1 30 6d 15 88       	mov    0x88156d30,%eax
80100253:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100256:	89 1d 30 6d 15 88    	mov    %ebx,0x88156d30
  }
  
  release(&bcache.lock);
8010025c:	c7 45 08 e0 25 15 88 	movl   $0x881525e0,0x8(%ebp)
}
80100263:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100266:	5b                   	pop    %ebx
80100267:	5e                   	pop    %esi
80100268:	5d                   	pop    %ebp
  release(&bcache.lock);
80100269:	e9 f2 42 00 00       	jmp    80104560 <release>
    panic("brelse");
8010026e:	83 ec 0c             	sub    $0xc,%esp
80100271:	68 86 6f 10 80       	push   $0x80106f86
80100276:	e8 05 01 00 00       	call   80100380 <panic>
8010027b:	66 90                	xchg   %ax,%ax
8010027d:	66 90                	xchg   %ax,%ax
8010027f:	90                   	nop

80100280 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100280:	55                   	push   %ebp
80100281:	89 e5                	mov    %esp,%ebp
80100283:	57                   	push   %edi
80100284:	56                   	push   %esi
80100285:	53                   	push   %ebx
80100286:	83 ec 18             	sub    $0x18,%esp
80100289:	8b 5d 10             	mov    0x10(%ebp),%ebx
8010028c:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
8010028f:	ff 75 08             	push   0x8(%ebp)
  target = n;
80100292:	89 df                	mov    %ebx,%edi
  iunlock(ip);
80100294:	e8 e7 15 00 00       	call   80101880 <iunlock>
  acquire(&cons.lock);
80100299:	c7 04 24 e0 6f 15 88 	movl   $0x88156fe0,(%esp)
801002a0:	e8 fb 41 00 00       	call   801044a0 <acquire>
  while(n > 0){
801002a5:	83 c4 10             	add    $0x10,%esp
801002a8:	85 db                	test   %ebx,%ebx
801002aa:	0f 8e 94 00 00 00    	jle    80100344 <consoleread+0xc4>
    while(input.r == input.w){
801002b0:	a1 c0 6f 15 88       	mov    0x88156fc0,%eax
801002b5:	39 05 c4 6f 15 88    	cmp    %eax,0x88156fc4
801002bb:	74 25                	je     801002e2 <consoleread+0x62>
801002bd:	eb 59                	jmp    80100318 <consoleread+0x98>
801002bf:	90                   	nop
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002c0:	83 ec 08             	sub    $0x8,%esp
801002c3:	68 e0 6f 15 88       	push   $0x88156fe0
801002c8:	68 c0 6f 15 88       	push   $0x88156fc0
801002cd:	e8 ee 3b 00 00       	call   80103ec0 <sleep>
    while(input.r == input.w){
801002d2:	a1 c0 6f 15 88       	mov    0x88156fc0,%eax
801002d7:	83 c4 10             	add    $0x10,%esp
801002da:	3b 05 c4 6f 15 88    	cmp    0x88156fc4,%eax
801002e0:	75 36                	jne    80100318 <consoleread+0x98>
      if(myproc()->killed){
801002e2:	e8 39 36 00 00       	call   80103920 <myproc>
801002e7:	8b 48 24             	mov    0x24(%eax),%ecx
801002ea:	85 c9                	test   %ecx,%ecx
801002ec:	74 d2                	je     801002c0 <consoleread+0x40>
        release(&cons.lock);
801002ee:	83 ec 0c             	sub    $0xc,%esp
801002f1:	68 e0 6f 15 88       	push   $0x88156fe0
801002f6:	e8 65 42 00 00       	call   80104560 <release>
        ilock(ip);
801002fb:	5a                   	pop    %edx
801002fc:	ff 75 08             	push   0x8(%ebp)
801002ff:	e8 9c 14 00 00       	call   801017a0 <ilock>
        return -1;
80100304:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100307:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
8010030a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010030f:	5b                   	pop    %ebx
80100310:	5e                   	pop    %esi
80100311:	5f                   	pop    %edi
80100312:	5d                   	pop    %ebp
80100313:	c3                   	ret
80100314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100318:	8d 50 01             	lea    0x1(%eax),%edx
8010031b:	89 15 c0 6f 15 88    	mov    %edx,0x88156fc0
80100321:	89 c2                	mov    %eax,%edx
80100323:	83 e2 7f             	and    $0x7f,%edx
80100326:	0f be 8a 40 6f 15 88 	movsbl -0x77ea90c0(%edx),%ecx
    if(c == C('D')){  // EOF
8010032d:	80 f9 04             	cmp    $0x4,%cl
80100330:	74 37                	je     80100369 <consoleread+0xe9>
    *dst++ = c;
80100332:	83 c6 01             	add    $0x1,%esi
    --n;
80100335:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
80100338:	88 4e ff             	mov    %cl,-0x1(%esi)
    if(c == '\n')
8010033b:	83 f9 0a             	cmp    $0xa,%ecx
8010033e:	0f 85 64 ff ff ff    	jne    801002a8 <consoleread+0x28>
  release(&cons.lock);
80100344:	83 ec 0c             	sub    $0xc,%esp
80100347:	68 e0 6f 15 88       	push   $0x88156fe0
8010034c:	e8 0f 42 00 00       	call   80104560 <release>
  ilock(ip);
80100351:	58                   	pop    %eax
80100352:	ff 75 08             	push   0x8(%ebp)
80100355:	e8 46 14 00 00       	call   801017a0 <ilock>
  return target - n;
8010035a:	89 f8                	mov    %edi,%eax
8010035c:	83 c4 10             	add    $0x10,%esp
}
8010035f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
80100362:	29 d8                	sub    %ebx,%eax
}
80100364:	5b                   	pop    %ebx
80100365:	5e                   	pop    %esi
80100366:	5f                   	pop    %edi
80100367:	5d                   	pop    %ebp
80100368:	c3                   	ret
      if(n < target){
80100369:	39 fb                	cmp    %edi,%ebx
8010036b:	73 d7                	jae    80100344 <consoleread+0xc4>
        input.r--;
8010036d:	a3 c0 6f 15 88       	mov    %eax,0x88156fc0
80100372:	eb d0                	jmp    80100344 <consoleread+0xc4>
80100374:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010037b:	00 
8010037c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100380 <panic>:
{
80100380:	55                   	push   %ebp
80100381:	89 e5                	mov    %esp,%ebp
80100383:	56                   	push   %esi
80100384:	53                   	push   %ebx
80100385:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100388:	fa                   	cli
  cons.locking = 0;
80100389:	c7 05 14 70 15 88 00 	movl   $0x0,0x88157014
80100390:	00 00 00 
  getcallerpcs(&s, pcs);
80100393:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100396:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
80100399:	e8 32 25 00 00       	call   801028d0 <lapicid>
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	50                   	push   %eax
801003a2:	68 8d 6f 10 80       	push   $0x80106f8d
801003a7:	e8 04 03 00 00       	call   801006b0 <cprintf>
  cprintf(s);
801003ac:	58                   	pop    %eax
801003ad:	ff 75 08             	push   0x8(%ebp)
801003b0:	e8 fb 02 00 00       	call   801006b0 <cprintf>
  cprintf("\n");
801003b5:	c7 04 24 0f 74 10 80 	movl   $0x8010740f,(%esp)
801003bc:	e8 ef 02 00 00       	call   801006b0 <cprintf>
  getcallerpcs(&s, pcs);
801003c1:	8d 45 08             	lea    0x8(%ebp),%eax
801003c4:	5a                   	pop    %edx
801003c5:	59                   	pop    %ecx
801003c6:	53                   	push   %ebx
801003c7:	50                   	push   %eax
801003c8:	e8 93 3f 00 00       	call   80104360 <getcallerpcs>
  for(i=0; i<10; i++)
801003cd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
801003d0:	83 ec 08             	sub    $0x8,%esp
801003d3:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
801003d5:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
801003d8:	68 a1 6f 10 80       	push   $0x80106fa1
801003dd:	e8 ce 02 00 00       	call   801006b0 <cprintf>
  for(i=0; i<10; i++)
801003e2:	83 c4 10             	add    $0x10,%esp
801003e5:	39 f3                	cmp    %esi,%ebx
801003e7:	75 e7                	jne    801003d0 <panic+0x50>
  panicked = 1; // freeze other CPU
801003e9:	c7 05 18 70 15 88 01 	movl   $0x1,0x88157018
801003f0:	00 00 00 
  for(;;)
801003f3:	eb fe                	jmp    801003f3 <panic+0x73>
801003f5:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801003fc:	00 
801003fd:	8d 76 00             	lea    0x0(%esi),%esi

80100400 <consputc.part.0>:
consputc(int c)
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	57                   	push   %edi
80100404:	56                   	push   %esi
80100405:	53                   	push   %ebx
80100406:	83 ec 1c             	sub    $0x1c,%esp
  if(c == BACKSPACE){
80100409:	3d 00 01 00 00       	cmp    $0x100,%eax
8010040e:	0f 84 cc 00 00 00    	je     801004e0 <consputc.part.0+0xe0>
    uartputc(c);
80100414:	83 ec 0c             	sub    $0xc,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100417:	bf d4 03 00 00       	mov    $0x3d4,%edi
8010041c:	89 c3                	mov    %eax,%ebx
8010041e:	50                   	push   %eax
8010041f:	e8 5c 57 00 00       	call   80105b80 <uartputc>
80100424:	b8 0e 00 00 00       	mov    $0xe,%eax
80100429:	89 fa                	mov    %edi,%edx
8010042b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010042c:	be d5 03 00 00       	mov    $0x3d5,%esi
80100431:	89 f2                	mov    %esi,%edx
80100433:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100434:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100437:	89 fa                	mov    %edi,%edx
80100439:	b8 0f 00 00 00       	mov    $0xf,%eax
8010043e:	c1 e1 08             	shl    $0x8,%ecx
80100441:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100442:	89 f2                	mov    %esi,%edx
80100444:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100445:	0f b6 c0             	movzbl %al,%eax
  if(c == '\n')
80100448:	83 c4 10             	add    $0x10,%esp
  pos |= inb(CRTPORT+1);
8010044b:	09 c8                	or     %ecx,%eax
  if(c == '\n')
8010044d:	83 fb 0a             	cmp    $0xa,%ebx
80100450:	75 76                	jne    801004c8 <consputc.part.0+0xc8>
    pos += 80 - pos%80;
80100452:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
80100457:	f7 e2                	mul    %edx
80100459:	c1 ea 06             	shr    $0x6,%edx
8010045c:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010045f:	c1 e0 04             	shl    $0x4,%eax
80100462:	8d 70 50             	lea    0x50(%eax),%esi
  if(pos < 0 || pos > 25*80)
80100465:	81 fe d0 07 00 00    	cmp    $0x7d0,%esi
8010046b:	0f 8f 2f 01 00 00    	jg     801005a0 <consputc.part.0+0x1a0>
  if((pos/80) >= 24){  // Scroll up.
80100471:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
80100477:	0f 8f c3 00 00 00    	jg     80100540 <consputc.part.0+0x140>
  outb(CRTPORT+1, pos>>8);
8010047d:	89 f0                	mov    %esi,%eax
  crt[pos] = ' ' | 0x0700;
8010047f:	8d b4 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
80100486:	88 45 e7             	mov    %al,-0x19(%ebp)
  outb(CRTPORT+1, pos>>8);
80100489:	0f b6 fc             	movzbl %ah,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010048c:	bb d4 03 00 00       	mov    $0x3d4,%ebx
80100491:	b8 0e 00 00 00       	mov    $0xe,%eax
80100496:	89 da                	mov    %ebx,%edx
80100498:	ee                   	out    %al,(%dx)
80100499:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
8010049e:	89 f8                	mov    %edi,%eax
801004a0:	89 ca                	mov    %ecx,%edx
801004a2:	ee                   	out    %al,(%dx)
801004a3:	b8 0f 00 00 00       	mov    $0xf,%eax
801004a8:	89 da                	mov    %ebx,%edx
801004aa:	ee                   	out    %al,(%dx)
801004ab:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801004af:	89 ca                	mov    %ecx,%edx
801004b1:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801004b2:	b8 20 07 00 00       	mov    $0x720,%eax
801004b7:	66 89 06             	mov    %ax,(%esi)
}
801004ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
801004bd:	5b                   	pop    %ebx
801004be:	5e                   	pop    %esi
801004bf:	5f                   	pop    %edi
801004c0:	5d                   	pop    %ebp
801004c1:	c3                   	ret
801004c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801004c8:	0f b6 db             	movzbl %bl,%ebx
801004cb:	8d 70 01             	lea    0x1(%eax),%esi
801004ce:	80 cf 07             	or     $0x7,%bh
801004d1:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
801004d8:	80 
801004d9:	eb 8a                	jmp    80100465 <consputc.part.0+0x65>
801004db:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
    uartputc('\b'); uartputc(' '); uartputc('\b');
801004e0:	83 ec 0c             	sub    $0xc,%esp
801004e3:	be d4 03 00 00       	mov    $0x3d4,%esi
801004e8:	6a 08                	push   $0x8
801004ea:	e8 91 56 00 00       	call   80105b80 <uartputc>
801004ef:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801004f6:	e8 85 56 00 00       	call   80105b80 <uartputc>
801004fb:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100502:	e8 79 56 00 00       	call   80105b80 <uartputc>
80100507:	b8 0e 00 00 00       	mov    $0xe,%eax
8010050c:	89 f2                	mov    %esi,%edx
8010050e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010050f:	bb d5 03 00 00       	mov    $0x3d5,%ebx
80100514:	89 da                	mov    %ebx,%edx
80100516:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100517:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010051a:	89 f2                	mov    %esi,%edx
8010051c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100521:	c1 e1 08             	shl    $0x8,%ecx
80100524:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100525:	89 da                	mov    %ebx,%edx
80100527:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100528:	0f b6 f0             	movzbl %al,%esi
    if(pos > 0) --pos;
8010052b:	83 c4 10             	add    $0x10,%esp
8010052e:	09 ce                	or     %ecx,%esi
80100530:	74 5e                	je     80100590 <consputc.part.0+0x190>
80100532:	83 ee 01             	sub    $0x1,%esi
80100535:	e9 2b ff ff ff       	jmp    80100465 <consputc.part.0+0x65>
8010053a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100540:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
80100543:	8d 5e b0             	lea    -0x50(%esi),%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100546:	8d b4 36 60 7f 0b 80 	lea    -0x7ff480a0(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
8010054d:	bf 07 00 00 00       	mov    $0x7,%edi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100552:	68 60 0e 00 00       	push   $0xe60
80100557:	68 a0 80 0b 80       	push   $0x800b80a0
8010055c:	68 00 80 0b 80       	push   $0x800b8000
80100561:	e8 ea 40 00 00       	call   80104650 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100566:	b8 80 07 00 00       	mov    $0x780,%eax
8010056b:	83 c4 0c             	add    $0xc,%esp
8010056e:	29 d8                	sub    %ebx,%eax
80100570:	01 c0                	add    %eax,%eax
80100572:	50                   	push   %eax
80100573:	6a 00                	push   $0x0
80100575:	56                   	push   %esi
80100576:	e8 35 40 00 00       	call   801045b0 <memset>
  outb(CRTPORT+1, pos);
8010057b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010057e:	83 c4 10             	add    $0x10,%esp
80100581:	e9 06 ff ff ff       	jmp    8010048c <consputc.part.0+0x8c>
80100586:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010058d:	00 
8010058e:	66 90                	xchg   %ax,%ax
80100590:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
80100594:	be 00 80 0b 80       	mov    $0x800b8000,%esi
80100599:	31 ff                	xor    %edi,%edi
8010059b:	e9 ec fe ff ff       	jmp    8010048c <consputc.part.0+0x8c>
    panic("pos under/overflow");
801005a0:	83 ec 0c             	sub    $0xc,%esp
801005a3:	68 a5 6f 10 80       	push   $0x80106fa5
801005a8:	e8 d3 fd ff ff       	call   80100380 <panic>
801005ad:	8d 76 00             	lea    0x0(%esi),%esi

801005b0 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005b0:	55                   	push   %ebp
801005b1:	89 e5                	mov    %esp,%ebp
801005b3:	57                   	push   %edi
801005b4:	56                   	push   %esi
801005b5:	53                   	push   %ebx
801005b6:	83 ec 18             	sub    $0x18,%esp
801005b9:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005bc:	ff 75 08             	push   0x8(%ebp)
801005bf:	e8 bc 12 00 00       	call   80101880 <iunlock>
  acquire(&cons.lock);
801005c4:	c7 04 24 e0 6f 15 88 	movl   $0x88156fe0,(%esp)
801005cb:	e8 d0 3e 00 00       	call   801044a0 <acquire>
  for(i = 0; i < n; i++)
801005d0:	83 c4 10             	add    $0x10,%esp
801005d3:	85 f6                	test   %esi,%esi
801005d5:	7e 25                	jle    801005fc <consolewrite+0x4c>
801005d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801005da:	8d 3c 33             	lea    (%ebx,%esi,1),%edi
  if(panicked){
801005dd:	8b 15 18 70 15 88    	mov    0x88157018,%edx
    consputc(buf[i] & 0xff);
801005e3:	0f b6 03             	movzbl (%ebx),%eax
  if(panicked){
801005e6:	85 d2                	test   %edx,%edx
801005e8:	74 06                	je     801005f0 <consolewrite+0x40>
  asm volatile("cli");
801005ea:	fa                   	cli
    for(;;)
801005eb:	eb fe                	jmp    801005eb <consolewrite+0x3b>
801005ed:	8d 76 00             	lea    0x0(%esi),%esi
801005f0:	e8 0b fe ff ff       	call   80100400 <consputc.part.0>
  for(i = 0; i < n; i++)
801005f5:	83 c3 01             	add    $0x1,%ebx
801005f8:	39 fb                	cmp    %edi,%ebx
801005fa:	75 e1                	jne    801005dd <consolewrite+0x2d>
  release(&cons.lock);
801005fc:	83 ec 0c             	sub    $0xc,%esp
801005ff:	68 e0 6f 15 88       	push   $0x88156fe0
80100604:	e8 57 3f 00 00       	call   80104560 <release>
  ilock(ip);
80100609:	58                   	pop    %eax
8010060a:	ff 75 08             	push   0x8(%ebp)
8010060d:	e8 8e 11 00 00       	call   801017a0 <ilock>

  return n;
}
80100612:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100615:	89 f0                	mov    %esi,%eax
80100617:	5b                   	pop    %ebx
80100618:	5e                   	pop    %esi
80100619:	5f                   	pop    %edi
8010061a:	5d                   	pop    %ebp
8010061b:	c3                   	ret
8010061c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100620 <printint>:
{
80100620:	55                   	push   %ebp
80100621:	89 e5                	mov    %esp,%ebp
80100623:	57                   	push   %edi
80100624:	56                   	push   %esi
80100625:	53                   	push   %ebx
80100626:	89 d3                	mov    %edx,%ebx
80100628:	83 ec 2c             	sub    $0x2c,%esp
  if(sign && (sign = xx < 0))
8010062b:	85 c0                	test   %eax,%eax
8010062d:	79 05                	jns    80100634 <printint+0x14>
8010062f:	83 e1 01             	and    $0x1,%ecx
80100632:	75 64                	jne    80100698 <printint+0x78>
    x = xx;
80100634:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
8010063b:	89 c1                	mov    %eax,%ecx
  i = 0;
8010063d:	31 f6                	xor    %esi,%esi
8010063f:	90                   	nop
    buf[i++] = digits[x % base];
80100640:	89 c8                	mov    %ecx,%eax
80100642:	31 d2                	xor    %edx,%edx
80100644:	89 f7                	mov    %esi,%edi
80100646:	f7 f3                	div    %ebx
80100648:	8d 76 01             	lea    0x1(%esi),%esi
8010064b:	0f b6 92 60 74 10 80 	movzbl -0x7fef8ba0(%edx),%edx
80100652:	88 54 35 d7          	mov    %dl,-0x29(%ebp,%esi,1)
  }while((x /= base) != 0);
80100656:	89 ca                	mov    %ecx,%edx
80100658:	89 c1                	mov    %eax,%ecx
8010065a:	39 da                	cmp    %ebx,%edx
8010065c:	73 e2                	jae    80100640 <printint+0x20>
  if(sign)
8010065e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80100661:	85 c9                	test   %ecx,%ecx
80100663:	74 07                	je     8010066c <printint+0x4c>
    buf[i++] = '-';
80100665:	c6 44 35 d8 2d       	movb   $0x2d,-0x28(%ebp,%esi,1)
  while(--i >= 0)
8010066a:	89 f7                	mov    %esi,%edi
8010066c:	8d 5d d8             	lea    -0x28(%ebp),%ebx
8010066f:	01 df                	add    %ebx,%edi
  if(panicked){
80100671:	8b 15 18 70 15 88    	mov    0x88157018,%edx
    consputc(buf[i]);
80100677:	0f be 07             	movsbl (%edi),%eax
  if(panicked){
8010067a:	85 d2                	test   %edx,%edx
8010067c:	74 0a                	je     80100688 <printint+0x68>
8010067e:	fa                   	cli
    for(;;)
8010067f:	eb fe                	jmp    8010067f <printint+0x5f>
80100681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100688:	e8 73 fd ff ff       	call   80100400 <consputc.part.0>
  while(--i >= 0)
8010068d:	8d 47 ff             	lea    -0x1(%edi),%eax
80100690:	39 df                	cmp    %ebx,%edi
80100692:	74 11                	je     801006a5 <printint+0x85>
80100694:	89 c7                	mov    %eax,%edi
80100696:	eb d9                	jmp    80100671 <printint+0x51>
    x = -xx;
80100698:	f7 d8                	neg    %eax
  if(sign && (sign = xx < 0))
8010069a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
    x = -xx;
801006a1:	89 c1                	mov    %eax,%ecx
801006a3:	eb 98                	jmp    8010063d <printint+0x1d>
}
801006a5:	83 c4 2c             	add    $0x2c,%esp
801006a8:	5b                   	pop    %ebx
801006a9:	5e                   	pop    %esi
801006aa:	5f                   	pop    %edi
801006ab:	5d                   	pop    %ebp
801006ac:	c3                   	ret
801006ad:	8d 76 00             	lea    0x0(%esi),%esi

801006b0 <cprintf>:
{
801006b0:	55                   	push   %ebp
801006b1:	89 e5                	mov    %esp,%ebp
801006b3:	57                   	push   %edi
801006b4:	56                   	push   %esi
801006b5:	53                   	push   %ebx
801006b6:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801006b9:	8b 3d 14 70 15 88    	mov    0x88157014,%edi
  if (fmt == 0)
801006bf:	8b 75 08             	mov    0x8(%ebp),%esi
  if(locking)
801006c2:	85 ff                	test   %edi,%edi
801006c4:	0f 85 06 01 00 00    	jne    801007d0 <cprintf+0x120>
  if (fmt == 0)
801006ca:	85 f6                	test   %esi,%esi
801006cc:	0f 84 b7 01 00 00    	je     80100889 <cprintf+0x1d9>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006d2:	0f b6 06             	movzbl (%esi),%eax
801006d5:	85 c0                	test   %eax,%eax
801006d7:	74 5f                	je     80100738 <cprintf+0x88>
  argp = (uint*)(void*)(&fmt + 1);
801006d9:	8d 55 0c             	lea    0xc(%ebp),%edx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006dc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801006df:	31 db                	xor    %ebx,%ebx
801006e1:	89 d7                	mov    %edx,%edi
    if(c != '%'){
801006e3:	83 f8 25             	cmp    $0x25,%eax
801006e6:	75 58                	jne    80100740 <cprintf+0x90>
    c = fmt[++i] & 0xff;
801006e8:	83 c3 01             	add    $0x1,%ebx
801006eb:	0f b6 0c 1e          	movzbl (%esi,%ebx,1),%ecx
    if(c == 0)
801006ef:	85 c9                	test   %ecx,%ecx
801006f1:	74 3a                	je     8010072d <cprintf+0x7d>
    switch(c){
801006f3:	83 f9 70             	cmp    $0x70,%ecx
801006f6:	0f 84 b4 00 00 00    	je     801007b0 <cprintf+0x100>
801006fc:	7f 72                	jg     80100770 <cprintf+0xc0>
801006fe:	83 f9 25             	cmp    $0x25,%ecx
80100701:	74 4d                	je     80100750 <cprintf+0xa0>
80100703:	83 f9 64             	cmp    $0x64,%ecx
80100706:	75 76                	jne    8010077e <cprintf+0xce>
      printint(*argp++, 10, 1);
80100708:	8d 47 04             	lea    0x4(%edi),%eax
8010070b:	b9 01 00 00 00       	mov    $0x1,%ecx
80100710:	ba 0a 00 00 00       	mov    $0xa,%edx
80100715:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100718:	8b 07                	mov    (%edi),%eax
8010071a:	e8 01 ff ff ff       	call   80100620 <printint>
8010071f:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100722:	83 c3 01             	add    $0x1,%ebx
80100725:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
80100729:	85 c0                	test   %eax,%eax
8010072b:	75 b6                	jne    801006e3 <cprintf+0x33>
8010072d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  if(locking)
80100730:	85 ff                	test   %edi,%edi
80100732:	0f 85 bb 00 00 00    	jne    801007f3 <cprintf+0x143>
}
80100738:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010073b:	5b                   	pop    %ebx
8010073c:	5e                   	pop    %esi
8010073d:	5f                   	pop    %edi
8010073e:	5d                   	pop    %ebp
8010073f:	c3                   	ret
  if(panicked){
80100740:	8b 0d 18 70 15 88    	mov    0x88157018,%ecx
80100746:	85 c9                	test   %ecx,%ecx
80100748:	74 19                	je     80100763 <cprintf+0xb3>
8010074a:	fa                   	cli
    for(;;)
8010074b:	eb fe                	jmp    8010074b <cprintf+0x9b>
8010074d:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
80100750:	8b 0d 18 70 15 88    	mov    0x88157018,%ecx
80100756:	85 c9                	test   %ecx,%ecx
80100758:	0f 85 f2 00 00 00    	jne    80100850 <cprintf+0x1a0>
8010075e:	b8 25 00 00 00       	mov    $0x25,%eax
80100763:	e8 98 fc ff ff       	call   80100400 <consputc.part.0>
      break;
80100768:	eb b8                	jmp    80100722 <cprintf+0x72>
8010076a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    switch(c){
80100770:	83 f9 73             	cmp    $0x73,%ecx
80100773:	0f 84 8f 00 00 00    	je     80100808 <cprintf+0x158>
80100779:	83 f9 78             	cmp    $0x78,%ecx
8010077c:	74 32                	je     801007b0 <cprintf+0x100>
  if(panicked){
8010077e:	8b 15 18 70 15 88    	mov    0x88157018,%edx
80100784:	85 d2                	test   %edx,%edx
80100786:	0f 85 b8 00 00 00    	jne    80100844 <cprintf+0x194>
8010078c:	b8 25 00 00 00       	mov    $0x25,%eax
80100791:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80100794:	e8 67 fc ff ff       	call   80100400 <consputc.part.0>
80100799:	a1 18 70 15 88       	mov    0x88157018,%eax
8010079e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801007a1:	85 c0                	test   %eax,%eax
801007a3:	0f 84 cd 00 00 00    	je     80100876 <cprintf+0x1c6>
801007a9:	fa                   	cli
    for(;;)
801007aa:	eb fe                	jmp    801007aa <cprintf+0xfa>
801007ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      printint(*argp++, 16, 0);
801007b0:	8d 47 04             	lea    0x4(%edi),%eax
801007b3:	31 c9                	xor    %ecx,%ecx
801007b5:	ba 10 00 00 00       	mov    $0x10,%edx
801007ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
801007bd:	8b 07                	mov    (%edi),%eax
801007bf:	e8 5c fe ff ff       	call   80100620 <printint>
801007c4:	8b 7d e0             	mov    -0x20(%ebp),%edi
      break;
801007c7:	e9 56 ff ff ff       	jmp    80100722 <cprintf+0x72>
801007cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    acquire(&cons.lock);
801007d0:	83 ec 0c             	sub    $0xc,%esp
801007d3:	68 e0 6f 15 88       	push   $0x88156fe0
801007d8:	e8 c3 3c 00 00       	call   801044a0 <acquire>
  if (fmt == 0)
801007dd:	83 c4 10             	add    $0x10,%esp
801007e0:	85 f6                	test   %esi,%esi
801007e2:	0f 84 a1 00 00 00    	je     80100889 <cprintf+0x1d9>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007e8:	0f b6 06             	movzbl (%esi),%eax
801007eb:	85 c0                	test   %eax,%eax
801007ed:	0f 85 e6 fe ff ff    	jne    801006d9 <cprintf+0x29>
    release(&cons.lock);
801007f3:	83 ec 0c             	sub    $0xc,%esp
801007f6:	68 e0 6f 15 88       	push   $0x88156fe0
801007fb:	e8 60 3d 00 00       	call   80104560 <release>
80100800:	83 c4 10             	add    $0x10,%esp
80100803:	e9 30 ff ff ff       	jmp    80100738 <cprintf+0x88>
      if((s = (char*)*argp++) == 0)
80100808:	8b 17                	mov    (%edi),%edx
8010080a:	8d 47 04             	lea    0x4(%edi),%eax
8010080d:	85 d2                	test   %edx,%edx
8010080f:	74 27                	je     80100838 <cprintf+0x188>
      for(; *s; s++)
80100811:	0f b6 0a             	movzbl (%edx),%ecx
      if((s = (char*)*argp++) == 0)
80100814:	89 d7                	mov    %edx,%edi
      for(; *s; s++)
80100816:	84 c9                	test   %cl,%cl
80100818:	74 68                	je     80100882 <cprintf+0x1d2>
8010081a:	89 5d e0             	mov    %ebx,-0x20(%ebp)
8010081d:	89 fb                	mov    %edi,%ebx
8010081f:	89 f7                	mov    %esi,%edi
80100821:	89 c6                	mov    %eax,%esi
80100823:	0f be c1             	movsbl %cl,%eax
  if(panicked){
80100826:	8b 15 18 70 15 88    	mov    0x88157018,%edx
8010082c:	85 d2                	test   %edx,%edx
8010082e:	74 28                	je     80100858 <cprintf+0x1a8>
80100830:	fa                   	cli
    for(;;)
80100831:	eb fe                	jmp    80100831 <cprintf+0x181>
80100833:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
80100838:	b9 28 00 00 00       	mov    $0x28,%ecx
        s = "(null)";
8010083d:	bf b8 6f 10 80       	mov    $0x80106fb8,%edi
80100842:	eb d6                	jmp    8010081a <cprintf+0x16a>
80100844:	fa                   	cli
    for(;;)
80100845:	eb fe                	jmp    80100845 <cprintf+0x195>
80100847:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010084e:	00 
8010084f:	90                   	nop
80100850:	fa                   	cli
80100851:	eb fe                	jmp    80100851 <cprintf+0x1a1>
80100853:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
80100858:	e8 a3 fb ff ff       	call   80100400 <consputc.part.0>
      for(; *s; s++)
8010085d:	0f be 43 01          	movsbl 0x1(%ebx),%eax
80100861:	83 c3 01             	add    $0x1,%ebx
80100864:	84 c0                	test   %al,%al
80100866:	75 be                	jne    80100826 <cprintf+0x176>
      if((s = (char*)*argp++) == 0)
80100868:	89 f0                	mov    %esi,%eax
8010086a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
8010086d:	89 fe                	mov    %edi,%esi
8010086f:	89 c7                	mov    %eax,%edi
80100871:	e9 ac fe ff ff       	jmp    80100722 <cprintf+0x72>
80100876:	89 c8                	mov    %ecx,%eax
80100878:	e8 83 fb ff ff       	call   80100400 <consputc.part.0>
      break;
8010087d:	e9 a0 fe ff ff       	jmp    80100722 <cprintf+0x72>
      if((s = (char*)*argp++) == 0)
80100882:	89 c7                	mov    %eax,%edi
80100884:	e9 99 fe ff ff       	jmp    80100722 <cprintf+0x72>
    panic("null fmt");
80100889:	83 ec 0c             	sub    $0xc,%esp
8010088c:	68 bf 6f 10 80       	push   $0x80106fbf
80100891:	e8 ea fa ff ff       	call   80100380 <panic>
80100896:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010089d:	00 
8010089e:	66 90                	xchg   %ax,%ax

801008a0 <consoleintr>:
{
801008a0:	55                   	push   %ebp
801008a1:	89 e5                	mov    %esp,%ebp
801008a3:	57                   	push   %edi
  int c, doprocdump = 0;
801008a4:	31 ff                	xor    %edi,%edi
{
801008a6:	56                   	push   %esi
801008a7:	53                   	push   %ebx
801008a8:	83 ec 18             	sub    $0x18,%esp
801008ab:	8b 75 08             	mov    0x8(%ebp),%esi
  acquire(&cons.lock);
801008ae:	68 e0 6f 15 88       	push   $0x88156fe0
801008b3:	e8 e8 3b 00 00       	call   801044a0 <acquire>
  while((c = getc()) >= 0){
801008b8:	83 c4 10             	add    $0x10,%esp
801008bb:	ff d6                	call   *%esi
801008bd:	89 c3                	mov    %eax,%ebx
801008bf:	85 c0                	test   %eax,%eax
801008c1:	78 22                	js     801008e5 <consoleintr+0x45>
    switch(c){
801008c3:	83 fb 15             	cmp    $0x15,%ebx
801008c6:	74 47                	je     8010090f <consoleintr+0x6f>
801008c8:	7f 76                	jg     80100940 <consoleintr+0xa0>
801008ca:	83 fb 08             	cmp    $0x8,%ebx
801008cd:	74 76                	je     80100945 <consoleintr+0xa5>
801008cf:	83 fb 10             	cmp    $0x10,%ebx
801008d2:	0f 85 f8 00 00 00    	jne    801009d0 <consoleintr+0x130>
  while((c = getc()) >= 0){
801008d8:	ff d6                	call   *%esi
    switch(c){
801008da:	bf 01 00 00 00       	mov    $0x1,%edi
  while((c = getc()) >= 0){
801008df:	89 c3                	mov    %eax,%ebx
801008e1:	85 c0                	test   %eax,%eax
801008e3:	79 de                	jns    801008c3 <consoleintr+0x23>
  release(&cons.lock);
801008e5:	83 ec 0c             	sub    $0xc,%esp
801008e8:	68 e0 6f 15 88       	push   $0x88156fe0
801008ed:	e8 6e 3c 00 00       	call   80104560 <release>
  if(doprocdump) {
801008f2:	83 c4 10             	add    $0x10,%esp
801008f5:	85 ff                	test   %edi,%edi
801008f7:	0f 85 4b 01 00 00    	jne    80100a48 <consoleintr+0x1a8>
}
801008fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100900:	5b                   	pop    %ebx
80100901:	5e                   	pop    %esi
80100902:	5f                   	pop    %edi
80100903:	5d                   	pop    %ebp
80100904:	c3                   	ret
80100905:	b8 00 01 00 00       	mov    $0x100,%eax
8010090a:	e8 f1 fa ff ff       	call   80100400 <consputc.part.0>
      while(input.e != input.w &&
8010090f:	a1 c8 6f 15 88       	mov    0x88156fc8,%eax
80100914:	3b 05 c4 6f 15 88    	cmp    0x88156fc4,%eax
8010091a:	74 9f                	je     801008bb <consoleintr+0x1b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8010091c:	83 e8 01             	sub    $0x1,%eax
8010091f:	89 c2                	mov    %eax,%edx
80100921:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100924:	80 ba 40 6f 15 88 0a 	cmpb   $0xa,-0x77ea90c0(%edx)
8010092b:	74 8e                	je     801008bb <consoleintr+0x1b>
  if(panicked){
8010092d:	8b 15 18 70 15 88    	mov    0x88157018,%edx
        input.e--;
80100933:	a3 c8 6f 15 88       	mov    %eax,0x88156fc8
  if(panicked){
80100938:	85 d2                	test   %edx,%edx
8010093a:	74 c9                	je     80100905 <consoleintr+0x65>
8010093c:	fa                   	cli
    for(;;)
8010093d:	eb fe                	jmp    8010093d <consoleintr+0x9d>
8010093f:	90                   	nop
    switch(c){
80100940:	83 fb 7f             	cmp    $0x7f,%ebx
80100943:	75 2b                	jne    80100970 <consoleintr+0xd0>
      if(input.e != input.w){
80100945:	a1 c8 6f 15 88       	mov    0x88156fc8,%eax
8010094a:	3b 05 c4 6f 15 88    	cmp    0x88156fc4,%eax
80100950:	0f 84 65 ff ff ff    	je     801008bb <consoleintr+0x1b>
        input.e--;
80100956:	83 e8 01             	sub    $0x1,%eax
80100959:	a3 c8 6f 15 88       	mov    %eax,0x88156fc8
  if(panicked){
8010095e:	a1 18 70 15 88       	mov    0x88157018,%eax
80100963:	85 c0                	test   %eax,%eax
80100965:	0f 84 ce 00 00 00    	je     80100a39 <consoleintr+0x199>
8010096b:	fa                   	cli
    for(;;)
8010096c:	eb fe                	jmp    8010096c <consoleintr+0xcc>
8010096e:	66 90                	xchg   %ax,%ax
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100970:	a1 c8 6f 15 88       	mov    0x88156fc8,%eax
80100975:	89 c2                	mov    %eax,%edx
80100977:	2b 15 c0 6f 15 88    	sub    0x88156fc0,%edx
8010097d:	83 fa 7f             	cmp    $0x7f,%edx
80100980:	0f 87 35 ff ff ff    	ja     801008bb <consoleintr+0x1b>
  if(panicked){
80100986:	8b 0d 18 70 15 88    	mov    0x88157018,%ecx
        input.buf[input.e++ % INPUT_BUF] = c;
8010098c:	8d 50 01             	lea    0x1(%eax),%edx
8010098f:	83 e0 7f             	and    $0x7f,%eax
80100992:	89 15 c8 6f 15 88    	mov    %edx,0x88156fc8
80100998:	88 98 40 6f 15 88    	mov    %bl,-0x77ea90c0(%eax)
  if(panicked){
8010099e:	85 c9                	test   %ecx,%ecx
801009a0:	0f 85 ae 00 00 00    	jne    80100a54 <consoleintr+0x1b4>
801009a6:	89 d8                	mov    %ebx,%eax
801009a8:	e8 53 fa ff ff       	call   80100400 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009ad:	83 fb 0a             	cmp    $0xa,%ebx
801009b0:	74 68                	je     80100a1a <consoleintr+0x17a>
801009b2:	83 fb 04             	cmp    $0x4,%ebx
801009b5:	74 63                	je     80100a1a <consoleintr+0x17a>
801009b7:	a1 c0 6f 15 88       	mov    0x88156fc0,%eax
801009bc:	83 e8 80             	sub    $0xffffff80,%eax
801009bf:	39 05 c8 6f 15 88    	cmp    %eax,0x88156fc8
801009c5:	0f 85 f0 fe ff ff    	jne    801008bb <consoleintr+0x1b>
801009cb:	eb 52                	jmp    80100a1f <consoleintr+0x17f>
801009cd:	8d 76 00             	lea    0x0(%esi),%esi
      if(c != 0 && input.e-input.r < INPUT_BUF){
801009d0:	85 db                	test   %ebx,%ebx
801009d2:	0f 84 e3 fe ff ff    	je     801008bb <consoleintr+0x1b>
801009d8:	a1 c8 6f 15 88       	mov    0x88156fc8,%eax
801009dd:	89 c2                	mov    %eax,%edx
801009df:	2b 15 c0 6f 15 88    	sub    0x88156fc0,%edx
801009e5:	83 fa 7f             	cmp    $0x7f,%edx
801009e8:	0f 87 cd fe ff ff    	ja     801008bb <consoleintr+0x1b>
        input.buf[input.e++ % INPUT_BUF] = c;
801009ee:	8d 50 01             	lea    0x1(%eax),%edx
  if(panicked){
801009f1:	8b 0d 18 70 15 88    	mov    0x88157018,%ecx
        input.buf[input.e++ % INPUT_BUF] = c;
801009f7:	83 e0 7f             	and    $0x7f,%eax
        c = (c == '\r') ? '\n' : c;
801009fa:	83 fb 0d             	cmp    $0xd,%ebx
801009fd:	75 93                	jne    80100992 <consoleintr+0xf2>
        input.buf[input.e++ % INPUT_BUF] = c;
801009ff:	89 15 c8 6f 15 88    	mov    %edx,0x88156fc8
80100a05:	c6 80 40 6f 15 88 0a 	movb   $0xa,-0x77ea90c0(%eax)
  if(panicked){
80100a0c:	85 c9                	test   %ecx,%ecx
80100a0e:	75 44                	jne    80100a54 <consoleintr+0x1b4>
80100a10:	b8 0a 00 00 00       	mov    $0xa,%eax
80100a15:	e8 e6 f9 ff ff       	call   80100400 <consputc.part.0>
          input.w = input.e;
80100a1a:	a1 c8 6f 15 88       	mov    0x88156fc8,%eax
          wakeup(&input.r);
80100a1f:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100a22:	a3 c4 6f 15 88       	mov    %eax,0x88156fc4
          wakeup(&input.r);
80100a27:	68 c0 6f 15 88       	push   $0x88156fc0
80100a2c:	e8 3f 36 00 00       	call   80104070 <wakeup>
80100a31:	83 c4 10             	add    $0x10,%esp
80100a34:	e9 82 fe ff ff       	jmp    801008bb <consoleintr+0x1b>
80100a39:	b8 00 01 00 00       	mov    $0x100,%eax
80100a3e:	e8 bd f9 ff ff       	call   80100400 <consputc.part.0>
80100a43:	e9 73 fe ff ff       	jmp    801008bb <consoleintr+0x1b>
}
80100a48:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100a4b:	5b                   	pop    %ebx
80100a4c:	5e                   	pop    %esi
80100a4d:	5f                   	pop    %edi
80100a4e:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100a4f:	e9 fc 36 00 00       	jmp    80104150 <procdump>
80100a54:	fa                   	cli
    for(;;)
80100a55:	eb fe                	jmp    80100a55 <consoleintr+0x1b5>
80100a57:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80100a5e:	00 
80100a5f:	90                   	nop

80100a60 <consoleinit>:

void
consoleinit(void)
{
80100a60:	55                   	push   %ebp
80100a61:	89 e5                	mov    %esp,%ebp
80100a63:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100a66:	68 c8 6f 10 80       	push   $0x80106fc8
80100a6b:	68 e0 6f 15 88       	push   $0x88156fe0
80100a70:	e8 cb 38 00 00       	call   80104340 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100a75:	58                   	pop    %eax
80100a76:	5a                   	pop    %edx
80100a77:	6a 00                	push   $0x0
80100a79:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100a7b:	c7 05 cc 79 15 88 b0 	movl   $0x801005b0,0x881579cc
80100a82:	05 10 80 
  devsw[CONSOLE].read = consoleread;
80100a85:	c7 05 c8 79 15 88 80 	movl   $0x80100280,0x881579c8
80100a8c:	02 10 80 
  cons.locking = 1;
80100a8f:	c7 05 14 70 15 88 01 	movl   $0x1,0x88157014
80100a96:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100a99:	e8 c2 19 00 00       	call   80102460 <ioapicenable>
}
80100a9e:	83 c4 10             	add    $0x10,%esp
80100aa1:	c9                   	leave
80100aa2:	c3                   	ret
80100aa3:	66 90                	xchg   %ax,%ax
80100aa5:	66 90                	xchg   %ax,%ax
80100aa7:	66 90                	xchg   %ax,%ax
80100aa9:	66 90                	xchg   %ax,%ax
80100aab:	66 90                	xchg   %ax,%ax
80100aad:	66 90                	xchg   %ax,%ax
80100aaf:	90                   	nop

80100ab0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	57                   	push   %edi
80100ab4:	56                   	push   %esi
80100ab5:	53                   	push   %ebx
80100ab6:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100abc:	e8 5f 2e 00 00       	call   80103920 <myproc>
80100ac1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100ac7:	e8 74 22 00 00       	call   80102d40 <begin_op>

  if((ip = namei(path)) == 0){
80100acc:	83 ec 0c             	sub    $0xc,%esp
80100acf:	ff 75 08             	push   0x8(%ebp)
80100ad2:	e8 a9 15 00 00       	call   80102080 <namei>
80100ad7:	83 c4 10             	add    $0x10,%esp
80100ada:	85 c0                	test   %eax,%eax
80100adc:	0f 84 30 03 00 00    	je     80100e12 <exec+0x362>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100ae2:	83 ec 0c             	sub    $0xc,%esp
80100ae5:	89 c7                	mov    %eax,%edi
80100ae7:	50                   	push   %eax
80100ae8:	e8 b3 0c 00 00       	call   801017a0 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100aed:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100af3:	6a 34                	push   $0x34
80100af5:	6a 00                	push   $0x0
80100af7:	50                   	push   %eax
80100af8:	57                   	push   %edi
80100af9:	e8 b2 0f 00 00       	call   80101ab0 <readi>
80100afe:	83 c4 20             	add    $0x20,%esp
80100b01:	83 f8 34             	cmp    $0x34,%eax
80100b04:	0f 85 01 01 00 00    	jne    80100c0b <exec+0x15b>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100b0a:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100b11:	45 4c 46 
80100b14:	0f 85 f1 00 00 00    	jne    80100c0b <exec+0x15b>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100b1a:	e8 b1 61 00 00       	call   80106cd0 <setupkvm>
80100b1f:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100b25:	85 c0                	test   %eax,%eax
80100b27:	0f 84 de 00 00 00    	je     80100c0b <exec+0x15b>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b2d:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100b34:	00 
80100b35:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100b3b:	0f 84 a1 02 00 00    	je     80100de2 <exec+0x332>
  sz = 0;
80100b41:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100b48:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b4b:	31 db                	xor    %ebx,%ebx
80100b4d:	e9 8c 00 00 00       	jmp    80100bde <exec+0x12e>
80100b52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100b58:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100b5f:	75 6c                	jne    80100bcd <exec+0x11d>
      continue;
    if(ph.memsz < ph.filesz)
80100b61:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100b67:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100b6d:	0f 82 87 00 00 00    	jb     80100bfa <exec+0x14a>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100b73:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100b79:	72 7f                	jb     80100bfa <exec+0x14a>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100b7b:	83 ec 04             	sub    $0x4,%esp
80100b7e:	50                   	push   %eax
80100b7f:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100b85:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100b8b:	e8 60 5f 00 00       	call   80106af0 <allocuvm>
80100b90:	83 c4 10             	add    $0x10,%esp
80100b93:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100b99:	85 c0                	test   %eax,%eax
80100b9b:	74 5d                	je     80100bfa <exec+0x14a>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100b9d:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100ba3:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100ba8:	75 50                	jne    80100bfa <exec+0x14a>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100baa:	83 ec 0c             	sub    $0xc,%esp
80100bad:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100bb3:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100bb9:	57                   	push   %edi
80100bba:	50                   	push   %eax
80100bbb:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100bc1:	e8 6a 5e 00 00       	call   80106a30 <loaduvm>
80100bc6:	83 c4 20             	add    $0x20,%esp
80100bc9:	85 c0                	test   %eax,%eax
80100bcb:	78 2d                	js     80100bfa <exec+0x14a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bcd:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100bd4:	83 c3 01             	add    $0x1,%ebx
80100bd7:	83 c6 20             	add    $0x20,%esi
80100bda:	39 d8                	cmp    %ebx,%eax
80100bdc:	7e 52                	jle    80100c30 <exec+0x180>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bde:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100be4:	6a 20                	push   $0x20
80100be6:	56                   	push   %esi
80100be7:	50                   	push   %eax
80100be8:	57                   	push   %edi
80100be9:	e8 c2 0e 00 00       	call   80101ab0 <readi>
80100bee:	83 c4 10             	add    $0x10,%esp
80100bf1:	83 f8 20             	cmp    $0x20,%eax
80100bf4:	0f 84 5e ff ff ff    	je     80100b58 <exec+0xa8>
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
80100bfa:	83 ec 0c             	sub    $0xc,%esp
80100bfd:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100c03:	e8 48 60 00 00       	call   80106c50 <freevm>
  if(ip){
80100c08:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80100c0b:	83 ec 0c             	sub    $0xc,%esp
80100c0e:	57                   	push   %edi
80100c0f:	e8 1c 0e 00 00       	call   80101a30 <iunlockput>
    end_op();
80100c14:	e8 97 21 00 00       	call   80102db0 <end_op>
80100c19:	83 c4 10             	add    $0x10,%esp
    return -1;
80100c1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return -1;
}
80100c21:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100c24:	5b                   	pop    %ebx
80100c25:	5e                   	pop    %esi
80100c26:	5f                   	pop    %edi
80100c27:	5d                   	pop    %ebp
80100c28:	c3                   	ret
80100c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  sz = PGROUNDUP(sz);
80100c30:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
80100c36:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
80100c3c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c42:	8d 9e 00 20 00 00    	lea    0x2000(%esi),%ebx
  iunlockput(ip);
80100c48:	83 ec 0c             	sub    $0xc,%esp
80100c4b:	57                   	push   %edi
80100c4c:	e8 df 0d 00 00       	call   80101a30 <iunlockput>
  end_op();
80100c51:	e8 5a 21 00 00       	call   80102db0 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c56:	83 c4 0c             	add    $0xc,%esp
80100c59:	53                   	push   %ebx
80100c5a:	56                   	push   %esi
80100c5b:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100c61:	56                   	push   %esi
80100c62:	e8 89 5e 00 00       	call   80106af0 <allocuvm>
80100c67:	83 c4 10             	add    $0x10,%esp
80100c6a:	89 c7                	mov    %eax,%edi
80100c6c:	85 c0                	test   %eax,%eax
80100c6e:	0f 84 86 00 00 00    	je     80100cfa <exec+0x24a>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c74:	83 ec 08             	sub    $0x8,%esp
80100c77:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  sp = sz;
80100c7d:	89 fb                	mov    %edi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c7f:	50                   	push   %eax
80100c80:	56                   	push   %esi
  for(argc = 0; argv[argc]; argc++) {
80100c81:	31 f6                	xor    %esi,%esi
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c83:	e8 e8 60 00 00       	call   80106d70 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100c88:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c8b:	83 c4 10             	add    $0x10,%esp
80100c8e:	8b 10                	mov    (%eax),%edx
80100c90:	85 d2                	test   %edx,%edx
80100c92:	0f 84 56 01 00 00    	je     80100dee <exec+0x33e>
80100c98:	89 bd f0 fe ff ff    	mov    %edi,-0x110(%ebp)
80100c9e:	8b 7d 0c             	mov    0xc(%ebp),%edi
80100ca1:	eb 23                	jmp    80100cc6 <exec+0x216>
80100ca3:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
80100ca8:	8d 46 01             	lea    0x1(%esi),%eax
    ustack[3+argc] = sp;
80100cab:	89 9c b5 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%esi,4)
80100cb2:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
  for(argc = 0; argv[argc]; argc++) {
80100cb8:	8b 14 87             	mov    (%edi,%eax,4),%edx
80100cbb:	85 d2                	test   %edx,%edx
80100cbd:	74 51                	je     80100d10 <exec+0x260>
    if(argc >= MAXARG)
80100cbf:	83 f8 20             	cmp    $0x20,%eax
80100cc2:	74 36                	je     80100cfa <exec+0x24a>
80100cc4:	89 c6                	mov    %eax,%esi
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	52                   	push   %edx
80100cca:	e8 e1 3a 00 00       	call   801047b0 <strlen>
80100ccf:	29 c3                	sub    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100cd1:	58                   	pop    %eax
80100cd2:	ff 34 b7             	push   (%edi,%esi,4)
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cd5:	83 eb 01             	sub    $0x1,%ebx
80100cd8:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100cdb:	e8 d0 3a 00 00       	call   801047b0 <strlen>
80100ce0:	83 c0 01             	add    $0x1,%eax
80100ce3:	50                   	push   %eax
80100ce4:	ff 34 b7             	push   (%edi,%esi,4)
80100ce7:	53                   	push   %ebx
80100ce8:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100cee:	e8 dd 61 00 00       	call   80106ed0 <copyout>
80100cf3:	83 c4 20             	add    $0x20,%esp
80100cf6:	85 c0                	test   %eax,%eax
80100cf8:	79 ae                	jns    80100ca8 <exec+0x1f8>
    freevm(pgdir);
80100cfa:	83 ec 0c             	sub    $0xc,%esp
80100cfd:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d03:	e8 48 5f 00 00       	call   80106c50 <freevm>
80100d08:	83 c4 10             	add    $0x10,%esp
80100d0b:	e9 0c ff ff ff       	jmp    80100c1c <exec+0x16c>
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d10:	8d 14 b5 08 00 00 00 	lea    0x8(,%esi,4),%edx
  ustack[3+argc] = 0;
80100d17:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100d1d:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100d23:	8d 46 04             	lea    0x4(%esi),%eax
  sp -= (3+argc+1) * 4;
80100d26:	8d 72 0c             	lea    0xc(%edx),%esi
  ustack[3+argc] = 0;
80100d29:	c7 84 85 58 ff ff ff 	movl   $0x0,-0xa8(%ebp,%eax,4)
80100d30:	00 00 00 00 
  ustack[1] = argc;
80100d34:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  ustack[0] = 0xffffffff;  // fake return PC
80100d3a:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100d41:	ff ff ff 
  ustack[1] = argc;
80100d44:	89 85 5c ff ff ff    	mov    %eax,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d4a:	89 d8                	mov    %ebx,%eax
  sp -= (3+argc+1) * 4;
80100d4c:	29 f3                	sub    %esi,%ebx
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d4e:	29 d0                	sub    %edx,%eax
80100d50:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100d56:	56                   	push   %esi
80100d57:	51                   	push   %ecx
80100d58:	53                   	push   %ebx
80100d59:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d5f:	e8 6c 61 00 00       	call   80106ed0 <copyout>
80100d64:	83 c4 10             	add    $0x10,%esp
80100d67:	85 c0                	test   %eax,%eax
80100d69:	78 8f                	js     80100cfa <exec+0x24a>
  for(last=s=path; *s; s++)
80100d6b:	8b 45 08             	mov    0x8(%ebp),%eax
80100d6e:	8b 55 08             	mov    0x8(%ebp),%edx
80100d71:	0f b6 00             	movzbl (%eax),%eax
80100d74:	84 c0                	test   %al,%al
80100d76:	74 17                	je     80100d8f <exec+0x2df>
80100d78:	89 d1                	mov    %edx,%ecx
80100d7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      last = s+1;
80100d80:	83 c1 01             	add    $0x1,%ecx
80100d83:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100d85:	0f b6 01             	movzbl (%ecx),%eax
      last = s+1;
80100d88:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100d8b:	84 c0                	test   %al,%al
80100d8d:	75 f1                	jne    80100d80 <exec+0x2d0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100d8f:	83 ec 04             	sub    $0x4,%esp
80100d92:	6a 10                	push   $0x10
80100d94:	52                   	push   %edx
80100d95:	8b b5 ec fe ff ff    	mov    -0x114(%ebp),%esi
80100d9b:	8d 46 6c             	lea    0x6c(%esi),%eax
80100d9e:	50                   	push   %eax
80100d9f:	e8 cc 39 00 00       	call   80104770 <safestrcpy>
  curproc->pgdir = pgdir;
80100da4:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  oldpgdir = curproc->pgdir;
80100daa:	89 f0                	mov    %esi,%eax
80100dac:	8b 76 04             	mov    0x4(%esi),%esi
  curproc->sz = sz;
80100daf:	89 38                	mov    %edi,(%eax)
  curproc->pgdir = pgdir;
80100db1:	89 48 04             	mov    %ecx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100db4:	89 c1                	mov    %eax,%ecx
80100db6:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100dbc:	8b 40 18             	mov    0x18(%eax),%eax
80100dbf:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100dc2:	8b 41 18             	mov    0x18(%ecx),%eax
80100dc5:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100dc8:	89 0c 24             	mov    %ecx,(%esp)
80100dcb:	e8 d0 5a 00 00       	call   801068a0 <switchuvm>
  freevm(oldpgdir);
80100dd0:	89 34 24             	mov    %esi,(%esp)
80100dd3:	e8 78 5e 00 00       	call   80106c50 <freevm>
  return 0;
80100dd8:	83 c4 10             	add    $0x10,%esp
80100ddb:	31 c0                	xor    %eax,%eax
80100ddd:	e9 3f fe ff ff       	jmp    80100c21 <exec+0x171>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100de2:	bb 00 20 00 00       	mov    $0x2000,%ebx
80100de7:	31 f6                	xor    %esi,%esi
80100de9:	e9 5a fe ff ff       	jmp    80100c48 <exec+0x198>
  for(argc = 0; argv[argc]; argc++) {
80100dee:	be 10 00 00 00       	mov    $0x10,%esi
80100df3:	ba 04 00 00 00       	mov    $0x4,%edx
80100df8:	b8 03 00 00 00       	mov    $0x3,%eax
80100dfd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100e04:	00 00 00 
80100e07:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
80100e0d:	e9 17 ff ff ff       	jmp    80100d29 <exec+0x279>
    end_op();
80100e12:	e8 99 1f 00 00       	call   80102db0 <end_op>
    cprintf("exec: fail\n");
80100e17:	83 ec 0c             	sub    $0xc,%esp
80100e1a:	68 d0 6f 10 80       	push   $0x80106fd0
80100e1f:	e8 8c f8 ff ff       	call   801006b0 <cprintf>
    return -1;
80100e24:	83 c4 10             	add    $0x10,%esp
80100e27:	e9 f0 fd ff ff       	jmp    80100c1c <exec+0x16c>
80100e2c:	66 90                	xchg   %ax,%ax
80100e2e:	66 90                	xchg   %ax,%ax

80100e30 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100e30:	55                   	push   %ebp
80100e31:	89 e5                	mov    %esp,%ebp
80100e33:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100e36:	68 dc 6f 10 80       	push   $0x80106fdc
80100e3b:	68 20 70 15 88       	push   $0x88157020
80100e40:	e8 fb 34 00 00       	call   80104340 <initlock>
}
80100e45:	83 c4 10             	add    $0x10,%esp
80100e48:	c9                   	leave
80100e49:	c3                   	ret
80100e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100e50 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100e50:	55                   	push   %ebp
80100e51:	89 e5                	mov    %esp,%ebp
80100e53:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e54:	bb 54 70 15 88       	mov    $0x88157054,%ebx
{
80100e59:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100e5c:	68 20 70 15 88       	push   $0x88157020
80100e61:	e8 3a 36 00 00       	call   801044a0 <acquire>
80100e66:	83 c4 10             	add    $0x10,%esp
80100e69:	eb 10                	jmp    80100e7b <filealloc+0x2b>
80100e6b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e70:	83 c3 18             	add    $0x18,%ebx
80100e73:	81 fb b4 79 15 88    	cmp    $0x881579b4,%ebx
80100e79:	74 25                	je     80100ea0 <filealloc+0x50>
    if(f->ref == 0){
80100e7b:	8b 43 04             	mov    0x4(%ebx),%eax
80100e7e:	85 c0                	test   %eax,%eax
80100e80:	75 ee                	jne    80100e70 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100e82:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100e85:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100e8c:	68 20 70 15 88       	push   $0x88157020
80100e91:	e8 ca 36 00 00       	call   80104560 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100e96:	89 d8                	mov    %ebx,%eax
      return f;
80100e98:	83 c4 10             	add    $0x10,%esp
}
80100e9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e9e:	c9                   	leave
80100e9f:	c3                   	ret
  release(&ftable.lock);
80100ea0:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100ea3:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100ea5:	68 20 70 15 88       	push   $0x88157020
80100eaa:	e8 b1 36 00 00       	call   80104560 <release>
}
80100eaf:	89 d8                	mov    %ebx,%eax
  return 0;
80100eb1:	83 c4 10             	add    $0x10,%esp
}
80100eb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100eb7:	c9                   	leave
80100eb8:	c3                   	ret
80100eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100ec0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100ec0:	55                   	push   %ebp
80100ec1:	89 e5                	mov    %esp,%ebp
80100ec3:	53                   	push   %ebx
80100ec4:	83 ec 10             	sub    $0x10,%esp
80100ec7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100eca:	68 20 70 15 88       	push   $0x88157020
80100ecf:	e8 cc 35 00 00       	call   801044a0 <acquire>
  if(f->ref < 1)
80100ed4:	8b 43 04             	mov    0x4(%ebx),%eax
80100ed7:	83 c4 10             	add    $0x10,%esp
80100eda:	85 c0                	test   %eax,%eax
80100edc:	7e 1a                	jle    80100ef8 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100ede:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100ee1:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100ee4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ee7:	68 20 70 15 88       	push   $0x88157020
80100eec:	e8 6f 36 00 00       	call   80104560 <release>
  return f;
}
80100ef1:	89 d8                	mov    %ebx,%eax
80100ef3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ef6:	c9                   	leave
80100ef7:	c3                   	ret
    panic("filedup");
80100ef8:	83 ec 0c             	sub    $0xc,%esp
80100efb:	68 e3 6f 10 80       	push   $0x80106fe3
80100f00:	e8 7b f4 ff ff       	call   80100380 <panic>
80100f05:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80100f0c:	00 
80100f0d:	8d 76 00             	lea    0x0(%esi),%esi

80100f10 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100f10:	55                   	push   %ebp
80100f11:	89 e5                	mov    %esp,%ebp
80100f13:	57                   	push   %edi
80100f14:	56                   	push   %esi
80100f15:	53                   	push   %ebx
80100f16:	83 ec 28             	sub    $0x28,%esp
80100f19:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100f1c:	68 20 70 15 88       	push   $0x88157020
80100f21:	e8 7a 35 00 00       	call   801044a0 <acquire>
  if(f->ref < 1)
80100f26:	8b 53 04             	mov    0x4(%ebx),%edx
80100f29:	83 c4 10             	add    $0x10,%esp
80100f2c:	85 d2                	test   %edx,%edx
80100f2e:	0f 8e a5 00 00 00    	jle    80100fd9 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80100f34:	83 ea 01             	sub    $0x1,%edx
80100f37:	89 53 04             	mov    %edx,0x4(%ebx)
80100f3a:	75 44                	jne    80100f80 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100f3c:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100f40:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80100f43:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80100f45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
80100f4b:	8b 73 0c             	mov    0xc(%ebx),%esi
80100f4e:	88 45 e7             	mov    %al,-0x19(%ebp)
80100f51:	8b 43 10             	mov    0x10(%ebx),%eax
80100f54:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80100f57:	68 20 70 15 88       	push   $0x88157020
80100f5c:	e8 ff 35 00 00       	call   80104560 <release>

  if(ff.type == FD_PIPE)
80100f61:	83 c4 10             	add    $0x10,%esp
80100f64:	83 ff 01             	cmp    $0x1,%edi
80100f67:	74 57                	je     80100fc0 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100f69:	83 ff 02             	cmp    $0x2,%edi
80100f6c:	74 2a                	je     80100f98 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100f6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f71:	5b                   	pop    %ebx
80100f72:	5e                   	pop    %esi
80100f73:	5f                   	pop    %edi
80100f74:	5d                   	pop    %ebp
80100f75:	c3                   	ret
80100f76:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80100f7d:	00 
80100f7e:	66 90                	xchg   %ax,%ax
    release(&ftable.lock);
80100f80:	c7 45 08 20 70 15 88 	movl   $0x88157020,0x8(%ebp)
}
80100f87:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f8a:	5b                   	pop    %ebx
80100f8b:	5e                   	pop    %esi
80100f8c:	5f                   	pop    %edi
80100f8d:	5d                   	pop    %ebp
    release(&ftable.lock);
80100f8e:	e9 cd 35 00 00       	jmp    80104560 <release>
80100f93:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
    begin_op();
80100f98:	e8 a3 1d 00 00       	call   80102d40 <begin_op>
    iput(ff.ip);
80100f9d:	83 ec 0c             	sub    $0xc,%esp
80100fa0:	ff 75 e0             	push   -0x20(%ebp)
80100fa3:	e8 28 09 00 00       	call   801018d0 <iput>
    end_op();
80100fa8:	83 c4 10             	add    $0x10,%esp
}
80100fab:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fae:	5b                   	pop    %ebx
80100faf:	5e                   	pop    %esi
80100fb0:	5f                   	pop    %edi
80100fb1:	5d                   	pop    %ebp
    end_op();
80100fb2:	e9 f9 1d 00 00       	jmp    80102db0 <end_op>
80100fb7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80100fbe:	00 
80100fbf:	90                   	nop
    pipeclose(ff.pipe, ff.writable);
80100fc0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
80100fc4:	83 ec 08             	sub    $0x8,%esp
80100fc7:	53                   	push   %ebx
80100fc8:	56                   	push   %esi
80100fc9:	e8 02 25 00 00       	call   801034d0 <pipeclose>
80100fce:	83 c4 10             	add    $0x10,%esp
}
80100fd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fd4:	5b                   	pop    %ebx
80100fd5:	5e                   	pop    %esi
80100fd6:	5f                   	pop    %edi
80100fd7:	5d                   	pop    %ebp
80100fd8:	c3                   	ret
    panic("fileclose");
80100fd9:	83 ec 0c             	sub    $0xc,%esp
80100fdc:	68 eb 6f 10 80       	push   $0x80106feb
80100fe1:	e8 9a f3 ff ff       	call   80100380 <panic>
80100fe6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80100fed:	00 
80100fee:	66 90                	xchg   %ax,%ax

80100ff0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100ff0:	55                   	push   %ebp
80100ff1:	89 e5                	mov    %esp,%ebp
80100ff3:	53                   	push   %ebx
80100ff4:	83 ec 04             	sub    $0x4,%esp
80100ff7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100ffa:	83 3b 02             	cmpl   $0x2,(%ebx)
80100ffd:	75 31                	jne    80101030 <filestat+0x40>
    ilock(f->ip);
80100fff:	83 ec 0c             	sub    $0xc,%esp
80101002:	ff 73 10             	push   0x10(%ebx)
80101005:	e8 96 07 00 00       	call   801017a0 <ilock>
    stati(f->ip, st);
8010100a:	58                   	pop    %eax
8010100b:	5a                   	pop    %edx
8010100c:	ff 75 0c             	push   0xc(%ebp)
8010100f:	ff 73 10             	push   0x10(%ebx)
80101012:	e8 69 0a 00 00       	call   80101a80 <stati>
    iunlock(f->ip);
80101017:	59                   	pop    %ecx
80101018:	ff 73 10             	push   0x10(%ebx)
8010101b:	e8 60 08 00 00       	call   80101880 <iunlock>
    return 0;
  }
  return -1;
}
80101020:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
80101023:	83 c4 10             	add    $0x10,%esp
80101026:	31 c0                	xor    %eax,%eax
}
80101028:	c9                   	leave
80101029:	c3                   	ret
8010102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101030:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80101033:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101038:	c9                   	leave
80101039:	c3                   	ret
8010103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101040 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101040:	55                   	push   %ebp
80101041:	89 e5                	mov    %esp,%ebp
80101043:	57                   	push   %edi
80101044:	56                   	push   %esi
80101045:	53                   	push   %ebx
80101046:	83 ec 0c             	sub    $0xc,%esp
80101049:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010104c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010104f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101052:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80101056:	74 60                	je     801010b8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80101058:	8b 03                	mov    (%ebx),%eax
8010105a:	83 f8 01             	cmp    $0x1,%eax
8010105d:	74 41                	je     801010a0 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010105f:	83 f8 02             	cmp    $0x2,%eax
80101062:	75 5b                	jne    801010bf <fileread+0x7f>
    ilock(f->ip);
80101064:	83 ec 0c             	sub    $0xc,%esp
80101067:	ff 73 10             	push   0x10(%ebx)
8010106a:	e8 31 07 00 00       	call   801017a0 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010106f:	57                   	push   %edi
80101070:	ff 73 14             	push   0x14(%ebx)
80101073:	56                   	push   %esi
80101074:	ff 73 10             	push   0x10(%ebx)
80101077:	e8 34 0a 00 00       	call   80101ab0 <readi>
8010107c:	83 c4 20             	add    $0x20,%esp
8010107f:	89 c6                	mov    %eax,%esi
80101081:	85 c0                	test   %eax,%eax
80101083:	7e 03                	jle    80101088 <fileread+0x48>
      f->off += r;
80101085:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101088:	83 ec 0c             	sub    $0xc,%esp
8010108b:	ff 73 10             	push   0x10(%ebx)
8010108e:	e8 ed 07 00 00       	call   80101880 <iunlock>
    return r;
80101093:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80101096:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101099:	89 f0                	mov    %esi,%eax
8010109b:	5b                   	pop    %ebx
8010109c:	5e                   	pop    %esi
8010109d:	5f                   	pop    %edi
8010109e:	5d                   	pop    %ebp
8010109f:	c3                   	ret
    return piperead(f->pipe, addr, n);
801010a0:	8b 43 0c             	mov    0xc(%ebx),%eax
801010a3:	89 45 08             	mov    %eax,0x8(%ebp)
}
801010a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010a9:	5b                   	pop    %ebx
801010aa:	5e                   	pop    %esi
801010ab:	5f                   	pop    %edi
801010ac:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
801010ad:	e9 be 25 00 00       	jmp    80103670 <piperead>
801010b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801010b8:	be ff ff ff ff       	mov    $0xffffffff,%esi
801010bd:	eb d7                	jmp    80101096 <fileread+0x56>
  panic("fileread");
801010bf:	83 ec 0c             	sub    $0xc,%esp
801010c2:	68 f5 6f 10 80       	push   $0x80106ff5
801010c7:	e8 b4 f2 ff ff       	call   80100380 <panic>
801010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801010d0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801010d0:	55                   	push   %ebp
801010d1:	89 e5                	mov    %esp,%ebp
801010d3:	57                   	push   %edi
801010d4:	56                   	push   %esi
801010d5:	53                   	push   %ebx
801010d6:	83 ec 1c             	sub    $0x1c,%esp
801010d9:	8b 45 0c             	mov    0xc(%ebp),%eax
801010dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
801010df:	89 45 dc             	mov    %eax,-0x24(%ebp)
801010e2:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
801010e5:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
{
801010e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
801010ec:	0f 84 bb 00 00 00    	je     801011ad <filewrite+0xdd>
    return -1;
  if(f->type == FD_PIPE)
801010f2:	8b 03                	mov    (%ebx),%eax
801010f4:	83 f8 01             	cmp    $0x1,%eax
801010f7:	0f 84 bf 00 00 00    	je     801011bc <filewrite+0xec>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
801010fd:	83 f8 02             	cmp    $0x2,%eax
80101100:	0f 85 c8 00 00 00    	jne    801011ce <filewrite+0xfe>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101106:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
80101109:	31 f6                	xor    %esi,%esi
    while(i < n){
8010110b:	85 c0                	test   %eax,%eax
8010110d:	7f 30                	jg     8010113f <filewrite+0x6f>
8010110f:	e9 94 00 00 00       	jmp    801011a8 <filewrite+0xd8>
80101114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101118:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
8010111b:	83 ec 0c             	sub    $0xc,%esp
        f->off += r;
8010111e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101121:	ff 73 10             	push   0x10(%ebx)
80101124:	e8 57 07 00 00       	call   80101880 <iunlock>
      end_op();
80101129:	e8 82 1c 00 00       	call   80102db0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
8010112e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101131:	83 c4 10             	add    $0x10,%esp
80101134:	39 c7                	cmp    %eax,%edi
80101136:	75 5c                	jne    80101194 <filewrite+0xc4>
        panic("short filewrite");
      i += r;
80101138:	01 fe                	add    %edi,%esi
    while(i < n){
8010113a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
8010113d:	7e 69                	jle    801011a8 <filewrite+0xd8>
      int n1 = n - i;
8010113f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
      if(n1 > max)
80101142:	b8 00 06 00 00       	mov    $0x600,%eax
      int n1 = n - i;
80101147:	29 f7                	sub    %esi,%edi
      if(n1 > max)
80101149:	39 c7                	cmp    %eax,%edi
8010114b:	0f 4f f8             	cmovg  %eax,%edi
      begin_op();
8010114e:	e8 ed 1b 00 00       	call   80102d40 <begin_op>
      ilock(f->ip);
80101153:	83 ec 0c             	sub    $0xc,%esp
80101156:	ff 73 10             	push   0x10(%ebx)
80101159:	e8 42 06 00 00       	call   801017a0 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010115e:	57                   	push   %edi
8010115f:	ff 73 14             	push   0x14(%ebx)
80101162:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101165:	01 f0                	add    %esi,%eax
80101167:	50                   	push   %eax
80101168:	ff 73 10             	push   0x10(%ebx)
8010116b:	e8 40 0a 00 00       	call   80101bb0 <writei>
80101170:	83 c4 20             	add    $0x20,%esp
80101173:	85 c0                	test   %eax,%eax
80101175:	7f a1                	jg     80101118 <filewrite+0x48>
80101177:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	ff 73 10             	push   0x10(%ebx)
80101180:	e8 fb 06 00 00       	call   80101880 <iunlock>
      end_op();
80101185:	e8 26 1c 00 00       	call   80102db0 <end_op>
      if(r < 0)
8010118a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010118d:	83 c4 10             	add    $0x10,%esp
80101190:	85 c0                	test   %eax,%eax
80101192:	75 14                	jne    801011a8 <filewrite+0xd8>
        panic("short filewrite");
80101194:	83 ec 0c             	sub    $0xc,%esp
80101197:	68 fe 6f 10 80       	push   $0x80106ffe
8010119c:	e8 df f1 ff ff       	call   80100380 <panic>
801011a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
    return i == n ? n : -1;
801011a8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
801011ab:	74 05                	je     801011b2 <filewrite+0xe2>
801011ad:	be ff ff ff ff       	mov    $0xffffffff,%esi
  }
  panic("filewrite");
}
801011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011b5:	89 f0                	mov    %esi,%eax
801011b7:	5b                   	pop    %ebx
801011b8:	5e                   	pop    %esi
801011b9:	5f                   	pop    %edi
801011ba:	5d                   	pop    %ebp
801011bb:	c3                   	ret
    return pipewrite(f->pipe, addr, n);
801011bc:	8b 43 0c             	mov    0xc(%ebx),%eax
801011bf:	89 45 08             	mov    %eax,0x8(%ebp)
}
801011c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011c5:	5b                   	pop    %ebx
801011c6:	5e                   	pop    %esi
801011c7:	5f                   	pop    %edi
801011c8:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801011c9:	e9 a2 23 00 00       	jmp    80103570 <pipewrite>
  panic("filewrite");
801011ce:	83 ec 0c             	sub    $0xc,%esp
801011d1:	68 04 70 10 80       	push   $0x80107004
801011d6:	e8 a5 f1 ff ff       	call   80100380 <panic>
801011db:	66 90                	xchg   %ax,%ax
801011dd:	66 90                	xchg   %ax,%ax
801011df:	90                   	nop

801011e0 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801011e0:	55                   	push   %ebp
801011e1:	89 e5                	mov    %esp,%ebp
801011e3:	57                   	push   %edi
801011e4:	56                   	push   %esi
801011e5:	53                   	push   %ebx
801011e6:	83 ec 1c             	sub    $0x1c,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801011e9:	8b 0d 74 96 15 88    	mov    0x88159674,%ecx
{
801011ef:	89 45 dc             	mov    %eax,-0x24(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801011f2:	85 c9                	test   %ecx,%ecx
801011f4:	0f 84 8c 00 00 00    	je     80101286 <balloc+0xa6>
801011fa:	31 ff                	xor    %edi,%edi
    bp = bread(dev, BBLOCK(b, sb));
801011fc:	89 f8                	mov    %edi,%eax
801011fe:	83 ec 08             	sub    $0x8,%esp
80101201:	89 fe                	mov    %edi,%esi
80101203:	c1 f8 0c             	sar    $0xc,%eax
80101206:	03 05 8c 96 15 88    	add    0x8815968c,%eax
8010120c:	50                   	push   %eax
8010120d:	ff 75 dc             	push   -0x24(%ebp)
80101210:	e8 bb ee ff ff       	call   801000d0 <bread>
80101215:	83 c4 10             	add    $0x10,%esp
80101218:	89 7d d8             	mov    %edi,-0x28(%ebp)
8010121b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010121e:	a1 74 96 15 88       	mov    0x88159674,%eax
80101223:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101226:	31 c0                	xor    %eax,%eax
80101228:	eb 32                	jmp    8010125c <balloc+0x7c>
8010122a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
80101230:	89 c1                	mov    %eax,%ecx
80101232:	bb 01 00 00 00       	mov    $0x1,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101237:	8b 7d e4             	mov    -0x1c(%ebp),%edi
      m = 1 << (bi % 8);
8010123a:	83 e1 07             	and    $0x7,%ecx
8010123d:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010123f:	89 c1                	mov    %eax,%ecx
80101241:	c1 f9 03             	sar    $0x3,%ecx
80101244:	0f b6 7c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%edi
80101249:	89 fa                	mov    %edi,%edx
8010124b:	85 df                	test   %ebx,%edi
8010124d:	74 49                	je     80101298 <balloc+0xb8>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010124f:	83 c0 01             	add    $0x1,%eax
80101252:	83 c6 01             	add    $0x1,%esi
80101255:	3d 00 10 00 00       	cmp    $0x1000,%eax
8010125a:	74 07                	je     80101263 <balloc+0x83>
8010125c:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010125f:	39 d6                	cmp    %edx,%esi
80101261:	72 cd                	jb     80101230 <balloc+0x50>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101263:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101266:	83 ec 0c             	sub    $0xc,%esp
80101269:	ff 75 e4             	push   -0x1c(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010126c:	81 c7 00 10 00 00    	add    $0x1000,%edi
    brelse(bp);
80101272:	e8 79 ef ff ff       	call   801001f0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
80101277:	83 c4 10             	add    $0x10,%esp
8010127a:	3b 3d 74 96 15 88    	cmp    0x88159674,%edi
80101280:	0f 82 76 ff ff ff    	jb     801011fc <balloc+0x1c>
  }
  panic("balloc: out of blocks");
80101286:	83 ec 0c             	sub    $0xc,%esp
80101289:	68 0e 70 10 80       	push   $0x8010700e
8010128e:	e8 ed f0 ff ff       	call   80100380 <panic>
80101293:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
        bp->data[bi/8] |= m;  // Mark block in use.
80101298:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
8010129b:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
8010129e:	09 da                	or     %ebx,%edx
801012a0:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
801012a4:	57                   	push   %edi
801012a5:	e8 76 1c 00 00       	call   80102f20 <log_write>
        brelse(bp);
801012aa:	89 3c 24             	mov    %edi,(%esp)
801012ad:	e8 3e ef ff ff       	call   801001f0 <brelse>
  bp = bread(dev, bno);
801012b2:	58                   	pop    %eax
801012b3:	5a                   	pop    %edx
801012b4:	56                   	push   %esi
801012b5:	ff 75 dc             	push   -0x24(%ebp)
801012b8:	e8 13 ee ff ff       	call   801000d0 <bread>
  memset(bp->data, 0, BSIZE);
801012bd:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
801012c0:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
801012c2:	8d 40 5c             	lea    0x5c(%eax),%eax
801012c5:	68 00 02 00 00       	push   $0x200
801012ca:	6a 00                	push   $0x0
801012cc:	50                   	push   %eax
801012cd:	e8 de 32 00 00       	call   801045b0 <memset>
  log_write(bp);
801012d2:	89 1c 24             	mov    %ebx,(%esp)
801012d5:	e8 46 1c 00 00       	call   80102f20 <log_write>
  brelse(bp);
801012da:	89 1c 24             	mov    %ebx,(%esp)
801012dd:	e8 0e ef ff ff       	call   801001f0 <brelse>
}
801012e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012e5:	89 f0                	mov    %esi,%eax
801012e7:	5b                   	pop    %ebx
801012e8:	5e                   	pop    %esi
801012e9:	5f                   	pop    %edi
801012ea:	5d                   	pop    %ebp
801012eb:	c3                   	ret
801012ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801012f0 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801012f0:	55                   	push   %ebp
801012f1:	89 e5                	mov    %esp,%ebp
801012f3:	57                   	push   %edi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
801012f4:	31 ff                	xor    %edi,%edi
{
801012f6:	56                   	push   %esi
801012f7:	89 c6                	mov    %eax,%esi
801012f9:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801012fa:	bb 54 7a 15 88       	mov    $0x88157a54,%ebx
{
801012ff:	83 ec 28             	sub    $0x28,%esp
80101302:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101305:	68 20 7a 15 88       	push   $0x88157a20
8010130a:	e8 91 31 00 00       	call   801044a0 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010130f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
80101312:	83 c4 10             	add    $0x10,%esp
80101315:	eb 1b                	jmp    80101332 <iget+0x42>
80101317:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010131e:	00 
8010131f:	90                   	nop
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101320:	39 33                	cmp    %esi,(%ebx)
80101322:	74 6c                	je     80101390 <iget+0xa0>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101324:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010132a:	81 fb 74 96 15 88    	cmp    $0x88159674,%ebx
80101330:	74 26                	je     80101358 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101332:	8b 43 08             	mov    0x8(%ebx),%eax
80101335:	85 c0                	test   %eax,%eax
80101337:	7f e7                	jg     80101320 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101339:	85 ff                	test   %edi,%edi
8010133b:	75 e7                	jne    80101324 <iget+0x34>
8010133d:	85 c0                	test   %eax,%eax
8010133f:	75 76                	jne    801013b7 <iget+0xc7>
      empty = ip;
80101341:	89 df                	mov    %ebx,%edi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101343:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101349:	81 fb 74 96 15 88    	cmp    $0x88159674,%ebx
8010134f:	75 e1                	jne    80101332 <iget+0x42>
80101351:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101358:	85 ff                	test   %edi,%edi
8010135a:	74 79                	je     801013d5 <iget+0xe5>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
8010135c:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
8010135f:	89 37                	mov    %esi,(%edi)
  ip->inum = inum;
80101361:	89 57 04             	mov    %edx,0x4(%edi)
  ip->ref = 1;
80101364:	c7 47 08 01 00 00 00 	movl   $0x1,0x8(%edi)
  ip->valid = 0;
8010136b:	c7 47 4c 00 00 00 00 	movl   $0x0,0x4c(%edi)
  release(&icache.lock);
80101372:	68 20 7a 15 88       	push   $0x88157a20
80101377:	e8 e4 31 00 00       	call   80104560 <release>

  return ip;
8010137c:	83 c4 10             	add    $0x10,%esp
}
8010137f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101382:	89 f8                	mov    %edi,%eax
80101384:	5b                   	pop    %ebx
80101385:	5e                   	pop    %esi
80101386:	5f                   	pop    %edi
80101387:	5d                   	pop    %ebp
80101388:	c3                   	ret
80101389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101390:	39 53 04             	cmp    %edx,0x4(%ebx)
80101393:	75 8f                	jne    80101324 <iget+0x34>
      ip->ref++;
80101395:	83 c0 01             	add    $0x1,%eax
      release(&icache.lock);
80101398:	83 ec 0c             	sub    $0xc,%esp
      return ip;
8010139b:	89 df                	mov    %ebx,%edi
      ip->ref++;
8010139d:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801013a0:	68 20 7a 15 88       	push   $0x88157a20
801013a5:	e8 b6 31 00 00       	call   80104560 <release>
      return ip;
801013aa:	83 c4 10             	add    $0x10,%esp
}
801013ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013b0:	89 f8                	mov    %edi,%eax
801013b2:	5b                   	pop    %ebx
801013b3:	5e                   	pop    %esi
801013b4:	5f                   	pop    %edi
801013b5:	5d                   	pop    %ebp
801013b6:	c3                   	ret
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801013b7:	81 c3 90 00 00 00    	add    $0x90,%ebx
801013bd:	81 fb 74 96 15 88    	cmp    $0x88159674,%ebx
801013c3:	74 10                	je     801013d5 <iget+0xe5>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801013c5:	8b 43 08             	mov    0x8(%ebx),%eax
801013c8:	85 c0                	test   %eax,%eax
801013ca:	0f 8f 50 ff ff ff    	jg     80101320 <iget+0x30>
801013d0:	e9 68 ff ff ff       	jmp    8010133d <iget+0x4d>
    panic("iget: no inodes");
801013d5:	83 ec 0c             	sub    $0xc,%esp
801013d8:	68 24 70 10 80       	push   $0x80107024
801013dd:	e8 9e ef ff ff       	call   80100380 <panic>
801013e2:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801013e9:	00 
801013ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801013f0 <bfree>:
{
801013f0:	55                   	push   %ebp
801013f1:	89 c1                	mov    %eax,%ecx
  bp = bread(dev, BBLOCK(b, sb));
801013f3:	89 d0                	mov    %edx,%eax
801013f5:	c1 e8 0c             	shr    $0xc,%eax
{
801013f8:	89 e5                	mov    %esp,%ebp
801013fa:	56                   	push   %esi
801013fb:	53                   	push   %ebx
  bp = bread(dev, BBLOCK(b, sb));
801013fc:	03 05 8c 96 15 88    	add    0x8815968c,%eax
{
80101402:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
80101404:	83 ec 08             	sub    $0x8,%esp
80101407:	50                   	push   %eax
80101408:	51                   	push   %ecx
80101409:	e8 c2 ec ff ff       	call   801000d0 <bread>
  m = 1 << (bi % 8);
8010140e:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
80101410:	c1 fb 03             	sar    $0x3,%ebx
80101413:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101416:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101418:	83 e1 07             	and    $0x7,%ecx
8010141b:	b8 01 00 00 00       	mov    $0x1,%eax
  if((bp->data[bi/8] & m) == 0)
80101420:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
  m = 1 << (bi % 8);
80101426:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101428:	0f b6 4c 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%ecx
8010142d:	85 c1                	test   %eax,%ecx
8010142f:	74 23                	je     80101454 <bfree+0x64>
  bp->data[bi/8] &= ~m;
80101431:	f7 d0                	not    %eax
  log_write(bp);
80101433:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101436:	21 c8                	and    %ecx,%eax
80101438:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
8010143c:	56                   	push   %esi
8010143d:	e8 de 1a 00 00       	call   80102f20 <log_write>
  brelse(bp);
80101442:	89 34 24             	mov    %esi,(%esp)
80101445:	e8 a6 ed ff ff       	call   801001f0 <brelse>
}
8010144a:	83 c4 10             	add    $0x10,%esp
8010144d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101450:	5b                   	pop    %ebx
80101451:	5e                   	pop    %esi
80101452:	5d                   	pop    %ebp
80101453:	c3                   	ret
    panic("freeing free block");
80101454:	83 ec 0c             	sub    $0xc,%esp
80101457:	68 34 70 10 80       	push   $0x80107034
8010145c:	e8 1f ef ff ff       	call   80100380 <panic>
80101461:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80101468:	00 
80101469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101470 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101470:	55                   	push   %ebp
80101471:	89 e5                	mov    %esp,%ebp
80101473:	57                   	push   %edi
80101474:	56                   	push   %esi
80101475:	89 c6                	mov    %eax,%esi
80101477:	53                   	push   %ebx
80101478:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010147b:	83 fa 0b             	cmp    $0xb,%edx
8010147e:	0f 86 8c 00 00 00    	jbe    80101510 <bmap+0xa0>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101484:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
80101487:	83 fb 7f             	cmp    $0x7f,%ebx
8010148a:	0f 87 a2 00 00 00    	ja     80101532 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101490:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101496:	85 c0                	test   %eax,%eax
80101498:	74 5e                	je     801014f8 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
8010149a:	83 ec 08             	sub    $0x8,%esp
8010149d:	50                   	push   %eax
8010149e:	ff 36                	push   (%esi)
801014a0:	e8 2b ec ff ff       	call   801000d0 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
801014a5:	83 c4 10             	add    $0x10,%esp
801014a8:	8d 5c 98 5c          	lea    0x5c(%eax,%ebx,4),%ebx
    bp = bread(ip->dev, addr);
801014ac:	89 c2                	mov    %eax,%edx
    if((addr = a[bn]) == 0){
801014ae:	8b 3b                	mov    (%ebx),%edi
801014b0:	85 ff                	test   %edi,%edi
801014b2:	74 1c                	je     801014d0 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
801014b4:	83 ec 0c             	sub    $0xc,%esp
801014b7:	52                   	push   %edx
801014b8:	e8 33 ed ff ff       	call   801001f0 <brelse>
801014bd:	83 c4 10             	add    $0x10,%esp
    return addr;
  }

  panic("bmap: out of range");
}
801014c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014c3:	89 f8                	mov    %edi,%eax
801014c5:	5b                   	pop    %ebx
801014c6:	5e                   	pop    %esi
801014c7:	5f                   	pop    %edi
801014c8:	5d                   	pop    %ebp
801014c9:	c3                   	ret
801014ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801014d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      a[bn] = addr = balloc(ip->dev);
801014d3:	8b 06                	mov    (%esi),%eax
801014d5:	e8 06 fd ff ff       	call   801011e0 <balloc>
      log_write(bp);
801014da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014dd:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
801014e0:	89 03                	mov    %eax,(%ebx)
801014e2:	89 c7                	mov    %eax,%edi
      log_write(bp);
801014e4:	52                   	push   %edx
801014e5:	e8 36 1a 00 00       	call   80102f20 <log_write>
801014ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014ed:	83 c4 10             	add    $0x10,%esp
801014f0:	eb c2                	jmp    801014b4 <bmap+0x44>
801014f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801014f8:	8b 06                	mov    (%esi),%eax
801014fa:	e8 e1 fc ff ff       	call   801011e0 <balloc>
801014ff:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
80101505:	eb 93                	jmp    8010149a <bmap+0x2a>
80101507:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010150e:	00 
8010150f:	90                   	nop
    if((addr = ip->addrs[bn]) == 0)
80101510:	8d 5a 14             	lea    0x14(%edx),%ebx
80101513:	8b 7c 98 0c          	mov    0xc(%eax,%ebx,4),%edi
80101517:	85 ff                	test   %edi,%edi
80101519:	75 a5                	jne    801014c0 <bmap+0x50>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010151b:	8b 00                	mov    (%eax),%eax
8010151d:	e8 be fc ff ff       	call   801011e0 <balloc>
80101522:	89 44 9e 0c          	mov    %eax,0xc(%esi,%ebx,4)
80101526:	89 c7                	mov    %eax,%edi
}
80101528:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010152b:	5b                   	pop    %ebx
8010152c:	89 f8                	mov    %edi,%eax
8010152e:	5e                   	pop    %esi
8010152f:	5f                   	pop    %edi
80101530:	5d                   	pop    %ebp
80101531:	c3                   	ret
  panic("bmap: out of range");
80101532:	83 ec 0c             	sub    $0xc,%esp
80101535:	68 47 70 10 80       	push   $0x80107047
8010153a:	e8 41 ee ff ff       	call   80100380 <panic>
8010153f:	90                   	nop

80101540 <readsb>:
{
80101540:	55                   	push   %ebp
80101541:	89 e5                	mov    %esp,%ebp
80101543:	56                   	push   %esi
80101544:	53                   	push   %ebx
80101545:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101548:	83 ec 08             	sub    $0x8,%esp
8010154b:	6a 01                	push   $0x1
8010154d:	ff 75 08             	push   0x8(%ebp)
80101550:	e8 7b eb ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101555:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
80101558:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010155a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010155d:	6a 1c                	push   $0x1c
8010155f:	50                   	push   %eax
80101560:	56                   	push   %esi
80101561:	e8 ea 30 00 00       	call   80104650 <memmove>
  brelse(bp);
80101566:	83 c4 10             	add    $0x10,%esp
80101569:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010156c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010156f:	5b                   	pop    %ebx
80101570:	5e                   	pop    %esi
80101571:	5d                   	pop    %ebp
  brelse(bp);
80101572:	e9 79 ec ff ff       	jmp    801001f0 <brelse>
80101577:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010157e:	00 
8010157f:	90                   	nop

80101580 <iinit>:
{
80101580:	55                   	push   %ebp
80101581:	89 e5                	mov    %esp,%ebp
80101583:	53                   	push   %ebx
80101584:	bb 60 7a 15 88       	mov    $0x88157a60,%ebx
80101589:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010158c:	68 5a 70 10 80       	push   $0x8010705a
80101591:	68 20 7a 15 88       	push   $0x88157a20
80101596:	e8 a5 2d 00 00       	call   80104340 <initlock>
  for(i = 0; i < NINODE; i++) {
8010159b:	83 c4 10             	add    $0x10,%esp
8010159e:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
801015a0:	83 ec 08             	sub    $0x8,%esp
801015a3:	68 61 70 10 80       	push   $0x80107061
801015a8:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
801015a9:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
801015af:	e8 5c 2c 00 00       	call   80104210 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801015b4:	83 c4 10             	add    $0x10,%esp
801015b7:	81 fb 80 96 15 88    	cmp    $0x88159680,%ebx
801015bd:	75 e1                	jne    801015a0 <iinit+0x20>
  bp = bread(dev, 1);
801015bf:	83 ec 08             	sub    $0x8,%esp
801015c2:	6a 01                	push   $0x1
801015c4:	ff 75 08             	push   0x8(%ebp)
801015c7:	e8 04 eb ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801015cc:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801015cf:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801015d1:	8d 40 5c             	lea    0x5c(%eax),%eax
801015d4:	6a 1c                	push   $0x1c
801015d6:	50                   	push   %eax
801015d7:	68 74 96 15 88       	push   $0x88159674
801015dc:	e8 6f 30 00 00       	call   80104650 <memmove>
  brelse(bp);
801015e1:	89 1c 24             	mov    %ebx,(%esp)
801015e4:	e8 07 ec ff ff       	call   801001f0 <brelse>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801015e9:	ff 35 8c 96 15 88    	push   0x8815968c
801015ef:	ff 35 88 96 15 88    	push   0x88159688
801015f5:	ff 35 84 96 15 88    	push   0x88159684
801015fb:	ff 35 80 96 15 88    	push   0x88159680
80101601:	ff 35 7c 96 15 88    	push   0x8815967c
80101607:	ff 35 78 96 15 88    	push   0x88159678
8010160d:	ff 35 74 96 15 88    	push   0x88159674
80101613:	68 74 74 10 80       	push   $0x80107474
80101618:	e8 93 f0 ff ff       	call   801006b0 <cprintf>
}
8010161d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101620:	83 c4 30             	add    $0x30,%esp
80101623:	c9                   	leave
80101624:	c3                   	ret
80101625:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010162c:	00 
8010162d:	8d 76 00             	lea    0x0(%esi),%esi

80101630 <ialloc>:
{
80101630:	55                   	push   %ebp
80101631:	89 e5                	mov    %esp,%ebp
80101633:	57                   	push   %edi
80101634:	56                   	push   %esi
80101635:	53                   	push   %ebx
80101636:	83 ec 1c             	sub    $0x1c,%esp
80101639:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010163c:	83 3d 7c 96 15 88 01 	cmpl   $0x1,0x8815967c
{
80101643:	8b 75 08             	mov    0x8(%ebp),%esi
80101646:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101649:	0f 86 91 00 00 00    	jbe    801016e0 <ialloc+0xb0>
8010164f:	bf 01 00 00 00       	mov    $0x1,%edi
80101654:	eb 21                	jmp    80101677 <ialloc+0x47>
80101656:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010165d:	00 
8010165e:	66 90                	xchg   %ax,%ax
    brelse(bp);
80101660:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101663:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101666:	53                   	push   %ebx
80101667:	e8 84 eb ff ff       	call   801001f0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010166c:	83 c4 10             	add    $0x10,%esp
8010166f:	3b 3d 7c 96 15 88    	cmp    0x8815967c,%edi
80101675:	73 69                	jae    801016e0 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101677:	89 f8                	mov    %edi,%eax
80101679:	83 ec 08             	sub    $0x8,%esp
8010167c:	c1 e8 03             	shr    $0x3,%eax
8010167f:	03 05 88 96 15 88    	add    0x88159688,%eax
80101685:	50                   	push   %eax
80101686:	56                   	push   %esi
80101687:	e8 44 ea ff ff       	call   801000d0 <bread>
    if(dip->type == 0){  // a free inode
8010168c:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
8010168f:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
80101691:	89 f8                	mov    %edi,%eax
80101693:	83 e0 07             	and    $0x7,%eax
80101696:	c1 e0 06             	shl    $0x6,%eax
80101699:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010169d:	66 83 39 00          	cmpw   $0x0,(%ecx)
801016a1:	75 bd                	jne    80101660 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801016a3:	83 ec 04             	sub    $0x4,%esp
801016a6:	6a 40                	push   $0x40
801016a8:	6a 00                	push   $0x0
801016aa:	51                   	push   %ecx
801016ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801016ae:	e8 fd 2e 00 00       	call   801045b0 <memset>
      dip->type = type;
801016b3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801016b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801016ba:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801016bd:	89 1c 24             	mov    %ebx,(%esp)
801016c0:	e8 5b 18 00 00       	call   80102f20 <log_write>
      brelse(bp);
801016c5:	89 1c 24             	mov    %ebx,(%esp)
801016c8:	e8 23 eb ff ff       	call   801001f0 <brelse>
      return iget(dev, inum);
801016cd:	83 c4 10             	add    $0x10,%esp
}
801016d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
801016d3:	89 fa                	mov    %edi,%edx
}
801016d5:	5b                   	pop    %ebx
      return iget(dev, inum);
801016d6:	89 f0                	mov    %esi,%eax
}
801016d8:	5e                   	pop    %esi
801016d9:	5f                   	pop    %edi
801016da:	5d                   	pop    %ebp
      return iget(dev, inum);
801016db:	e9 10 fc ff ff       	jmp    801012f0 <iget>
  panic("ialloc: no inodes");
801016e0:	83 ec 0c             	sub    $0xc,%esp
801016e3:	68 67 70 10 80       	push   $0x80107067
801016e8:	e8 93 ec ff ff       	call   80100380 <panic>
801016ed:	8d 76 00             	lea    0x0(%esi),%esi

801016f0 <iupdate>:
{
801016f0:	55                   	push   %ebp
801016f1:	89 e5                	mov    %esp,%ebp
801016f3:	56                   	push   %esi
801016f4:	53                   	push   %ebx
801016f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016f8:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016fb:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016fe:	83 ec 08             	sub    $0x8,%esp
80101701:	c1 e8 03             	shr    $0x3,%eax
80101704:	03 05 88 96 15 88    	add    0x88159688,%eax
8010170a:	50                   	push   %eax
8010170b:	ff 73 a4             	push   -0x5c(%ebx)
8010170e:	e8 bd e9 ff ff       	call   801000d0 <bread>
  dip->type = ip->type;
80101713:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101717:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010171a:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010171c:	8b 43 a8             	mov    -0x58(%ebx),%eax
8010171f:	83 e0 07             	and    $0x7,%eax
80101722:	c1 e0 06             	shl    $0x6,%eax
80101725:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101729:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010172c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101730:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101733:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101737:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010173b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010173f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101743:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101747:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010174a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010174d:	6a 34                	push   $0x34
8010174f:	53                   	push   %ebx
80101750:	50                   	push   %eax
80101751:	e8 fa 2e 00 00       	call   80104650 <memmove>
  log_write(bp);
80101756:	89 34 24             	mov    %esi,(%esp)
80101759:	e8 c2 17 00 00       	call   80102f20 <log_write>
  brelse(bp);
8010175e:	83 c4 10             	add    $0x10,%esp
80101761:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101764:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101767:	5b                   	pop    %ebx
80101768:	5e                   	pop    %esi
80101769:	5d                   	pop    %ebp
  brelse(bp);
8010176a:	e9 81 ea ff ff       	jmp    801001f0 <brelse>
8010176f:	90                   	nop

80101770 <idup>:
{
80101770:	55                   	push   %ebp
80101771:	89 e5                	mov    %esp,%ebp
80101773:	53                   	push   %ebx
80101774:	83 ec 10             	sub    $0x10,%esp
80101777:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010177a:	68 20 7a 15 88       	push   $0x88157a20
8010177f:	e8 1c 2d 00 00       	call   801044a0 <acquire>
  ip->ref++;
80101784:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101788:	c7 04 24 20 7a 15 88 	movl   $0x88157a20,(%esp)
8010178f:	e8 cc 2d 00 00       	call   80104560 <release>
}
80101794:	89 d8                	mov    %ebx,%eax
80101796:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101799:	c9                   	leave
8010179a:	c3                   	ret
8010179b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

801017a0 <ilock>:
{
801017a0:	55                   	push   %ebp
801017a1:	89 e5                	mov    %esp,%ebp
801017a3:	56                   	push   %esi
801017a4:	53                   	push   %ebx
801017a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
801017a8:	85 db                	test   %ebx,%ebx
801017aa:	0f 84 b7 00 00 00    	je     80101867 <ilock+0xc7>
801017b0:	8b 53 08             	mov    0x8(%ebx),%edx
801017b3:	85 d2                	test   %edx,%edx
801017b5:	0f 8e ac 00 00 00    	jle    80101867 <ilock+0xc7>
  acquiresleep(&ip->lock);
801017bb:	83 ec 0c             	sub    $0xc,%esp
801017be:	8d 43 0c             	lea    0xc(%ebx),%eax
801017c1:	50                   	push   %eax
801017c2:	e8 89 2a 00 00       	call   80104250 <acquiresleep>
  if(ip->valid == 0){
801017c7:	8b 43 4c             	mov    0x4c(%ebx),%eax
801017ca:	83 c4 10             	add    $0x10,%esp
801017cd:	85 c0                	test   %eax,%eax
801017cf:	74 0f                	je     801017e0 <ilock+0x40>
}
801017d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801017d4:	5b                   	pop    %ebx
801017d5:	5e                   	pop    %esi
801017d6:	5d                   	pop    %ebp
801017d7:	c3                   	ret
801017d8:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801017df:	00 
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017e0:	8b 43 04             	mov    0x4(%ebx),%eax
801017e3:	83 ec 08             	sub    $0x8,%esp
801017e6:	c1 e8 03             	shr    $0x3,%eax
801017e9:	03 05 88 96 15 88    	add    0x88159688,%eax
801017ef:	50                   	push   %eax
801017f0:	ff 33                	push   (%ebx)
801017f2:	e8 d9 e8 ff ff       	call   801000d0 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017f7:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017fa:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801017fc:	8b 43 04             	mov    0x4(%ebx),%eax
801017ff:	83 e0 07             	and    $0x7,%eax
80101802:	c1 e0 06             	shl    $0x6,%eax
80101805:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101809:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010180c:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
8010180f:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101813:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101817:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010181b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
8010181f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101823:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101827:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010182b:	8b 50 fc             	mov    -0x4(%eax),%edx
8010182e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101831:	6a 34                	push   $0x34
80101833:	50                   	push   %eax
80101834:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101837:	50                   	push   %eax
80101838:	e8 13 2e 00 00       	call   80104650 <memmove>
    brelse(bp);
8010183d:	89 34 24             	mov    %esi,(%esp)
80101840:	e8 ab e9 ff ff       	call   801001f0 <brelse>
    if(ip->type == 0)
80101845:	83 c4 10             	add    $0x10,%esp
80101848:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
8010184d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101854:	0f 85 77 ff ff ff    	jne    801017d1 <ilock+0x31>
      panic("ilock: no type");
8010185a:	83 ec 0c             	sub    $0xc,%esp
8010185d:	68 7f 70 10 80       	push   $0x8010707f
80101862:	e8 19 eb ff ff       	call   80100380 <panic>
    panic("ilock");
80101867:	83 ec 0c             	sub    $0xc,%esp
8010186a:	68 79 70 10 80       	push   $0x80107079
8010186f:	e8 0c eb ff ff       	call   80100380 <panic>
80101874:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010187b:	00 
8010187c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101880 <iunlock>:
{
80101880:	55                   	push   %ebp
80101881:	89 e5                	mov    %esp,%ebp
80101883:	56                   	push   %esi
80101884:	53                   	push   %ebx
80101885:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101888:	85 db                	test   %ebx,%ebx
8010188a:	74 28                	je     801018b4 <iunlock+0x34>
8010188c:	83 ec 0c             	sub    $0xc,%esp
8010188f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101892:	56                   	push   %esi
80101893:	e8 58 2a 00 00       	call   801042f0 <holdingsleep>
80101898:	83 c4 10             	add    $0x10,%esp
8010189b:	85 c0                	test   %eax,%eax
8010189d:	74 15                	je     801018b4 <iunlock+0x34>
8010189f:	8b 43 08             	mov    0x8(%ebx),%eax
801018a2:	85 c0                	test   %eax,%eax
801018a4:	7e 0e                	jle    801018b4 <iunlock+0x34>
  releasesleep(&ip->lock);
801018a6:	89 75 08             	mov    %esi,0x8(%ebp)
}
801018a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801018ac:	5b                   	pop    %ebx
801018ad:	5e                   	pop    %esi
801018ae:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
801018af:	e9 fc 29 00 00       	jmp    801042b0 <releasesleep>
    panic("iunlock");
801018b4:	83 ec 0c             	sub    $0xc,%esp
801018b7:	68 8e 70 10 80       	push   $0x8010708e
801018bc:	e8 bf ea ff ff       	call   80100380 <panic>
801018c1:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801018c8:	00 
801018c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801018d0 <iput>:
{
801018d0:	55                   	push   %ebp
801018d1:	89 e5                	mov    %esp,%ebp
801018d3:	57                   	push   %edi
801018d4:	56                   	push   %esi
801018d5:	53                   	push   %ebx
801018d6:	83 ec 28             	sub    $0x28,%esp
801018d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801018dc:	8d 7b 0c             	lea    0xc(%ebx),%edi
801018df:	57                   	push   %edi
801018e0:	e8 6b 29 00 00       	call   80104250 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801018e5:	8b 53 4c             	mov    0x4c(%ebx),%edx
801018e8:	83 c4 10             	add    $0x10,%esp
801018eb:	85 d2                	test   %edx,%edx
801018ed:	74 07                	je     801018f6 <iput+0x26>
801018ef:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801018f4:	74 32                	je     80101928 <iput+0x58>
  releasesleep(&ip->lock);
801018f6:	83 ec 0c             	sub    $0xc,%esp
801018f9:	57                   	push   %edi
801018fa:	e8 b1 29 00 00       	call   801042b0 <releasesleep>
  acquire(&icache.lock);
801018ff:	c7 04 24 20 7a 15 88 	movl   $0x88157a20,(%esp)
80101906:	e8 95 2b 00 00       	call   801044a0 <acquire>
  ip->ref--;
8010190b:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
8010190f:	83 c4 10             	add    $0x10,%esp
80101912:	c7 45 08 20 7a 15 88 	movl   $0x88157a20,0x8(%ebp)
}
80101919:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010191c:	5b                   	pop    %ebx
8010191d:	5e                   	pop    %esi
8010191e:	5f                   	pop    %edi
8010191f:	5d                   	pop    %ebp
  release(&icache.lock);
80101920:	e9 3b 2c 00 00       	jmp    80104560 <release>
80101925:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101928:	83 ec 0c             	sub    $0xc,%esp
8010192b:	68 20 7a 15 88       	push   $0x88157a20
80101930:	e8 6b 2b 00 00       	call   801044a0 <acquire>
    int r = ip->ref;
80101935:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101938:	c7 04 24 20 7a 15 88 	movl   $0x88157a20,(%esp)
8010193f:	e8 1c 2c 00 00       	call   80104560 <release>
    if(r == 1){
80101944:	83 c4 10             	add    $0x10,%esp
80101947:	83 fe 01             	cmp    $0x1,%esi
8010194a:	75 aa                	jne    801018f6 <iput+0x26>
8010194c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101952:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101955:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101958:	89 df                	mov    %ebx,%edi
8010195a:	89 cb                	mov    %ecx,%ebx
8010195c:	eb 09                	jmp    80101967 <iput+0x97>
8010195e:	66 90                	xchg   %ax,%ax
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101960:	83 c6 04             	add    $0x4,%esi
80101963:	39 de                	cmp    %ebx,%esi
80101965:	74 19                	je     80101980 <iput+0xb0>
    if(ip->addrs[i]){
80101967:	8b 16                	mov    (%esi),%edx
80101969:	85 d2                	test   %edx,%edx
8010196b:	74 f3                	je     80101960 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
8010196d:	8b 07                	mov    (%edi),%eax
8010196f:	e8 7c fa ff ff       	call   801013f0 <bfree>
      ip->addrs[i] = 0;
80101974:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010197a:	eb e4                	jmp    80101960 <iput+0x90>
8010197c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101980:	89 fb                	mov    %edi,%ebx
80101982:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101985:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
8010198b:	85 c0                	test   %eax,%eax
8010198d:	75 2d                	jne    801019bc <iput+0xec>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
8010198f:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101992:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101999:	53                   	push   %ebx
8010199a:	e8 51 fd ff ff       	call   801016f0 <iupdate>
      ip->type = 0;
8010199f:	31 c0                	xor    %eax,%eax
801019a1:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
801019a5:	89 1c 24             	mov    %ebx,(%esp)
801019a8:	e8 43 fd ff ff       	call   801016f0 <iupdate>
      ip->valid = 0;
801019ad:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
801019b4:	83 c4 10             	add    $0x10,%esp
801019b7:	e9 3a ff ff ff       	jmp    801018f6 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801019bc:	83 ec 08             	sub    $0x8,%esp
801019bf:	50                   	push   %eax
801019c0:	ff 33                	push   (%ebx)
801019c2:	e8 09 e7 ff ff       	call   801000d0 <bread>
    for(j = 0; j < NINDIRECT; j++){
801019c7:	83 c4 10             	add    $0x10,%esp
801019ca:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801019cd:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
801019d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
801019d6:	8d 70 5c             	lea    0x5c(%eax),%esi
801019d9:	89 cf                	mov    %ecx,%edi
801019db:	eb 0a                	jmp    801019e7 <iput+0x117>
801019dd:	8d 76 00             	lea    0x0(%esi),%esi
801019e0:	83 c6 04             	add    $0x4,%esi
801019e3:	39 fe                	cmp    %edi,%esi
801019e5:	74 0f                	je     801019f6 <iput+0x126>
      if(a[j])
801019e7:	8b 16                	mov    (%esi),%edx
801019e9:	85 d2                	test   %edx,%edx
801019eb:	74 f3                	je     801019e0 <iput+0x110>
        bfree(ip->dev, a[j]);
801019ed:	8b 03                	mov    (%ebx),%eax
801019ef:	e8 fc f9 ff ff       	call   801013f0 <bfree>
801019f4:	eb ea                	jmp    801019e0 <iput+0x110>
    brelse(bp);
801019f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801019f9:	83 ec 0c             	sub    $0xc,%esp
801019fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801019ff:	50                   	push   %eax
80101a00:	e8 eb e7 ff ff       	call   801001f0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101a05:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101a0b:	8b 03                	mov    (%ebx),%eax
80101a0d:	e8 de f9 ff ff       	call   801013f0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101a12:	83 c4 10             	add    $0x10,%esp
80101a15:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101a1c:	00 00 00 
80101a1f:	e9 6b ff ff ff       	jmp    8010198f <iput+0xbf>
80101a24:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80101a2b:	00 
80101a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101a30 <iunlockput>:
{
80101a30:	55                   	push   %ebp
80101a31:	89 e5                	mov    %esp,%ebp
80101a33:	56                   	push   %esi
80101a34:	53                   	push   %ebx
80101a35:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a38:	85 db                	test   %ebx,%ebx
80101a3a:	74 34                	je     80101a70 <iunlockput+0x40>
80101a3c:	83 ec 0c             	sub    $0xc,%esp
80101a3f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101a42:	56                   	push   %esi
80101a43:	e8 a8 28 00 00       	call   801042f0 <holdingsleep>
80101a48:	83 c4 10             	add    $0x10,%esp
80101a4b:	85 c0                	test   %eax,%eax
80101a4d:	74 21                	je     80101a70 <iunlockput+0x40>
80101a4f:	8b 43 08             	mov    0x8(%ebx),%eax
80101a52:	85 c0                	test   %eax,%eax
80101a54:	7e 1a                	jle    80101a70 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101a56:	83 ec 0c             	sub    $0xc,%esp
80101a59:	56                   	push   %esi
80101a5a:	e8 51 28 00 00       	call   801042b0 <releasesleep>
  iput(ip);
80101a5f:	83 c4 10             	add    $0x10,%esp
80101a62:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80101a65:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101a68:	5b                   	pop    %ebx
80101a69:	5e                   	pop    %esi
80101a6a:	5d                   	pop    %ebp
  iput(ip);
80101a6b:	e9 60 fe ff ff       	jmp    801018d0 <iput>
    panic("iunlock");
80101a70:	83 ec 0c             	sub    $0xc,%esp
80101a73:	68 8e 70 10 80       	push   $0x8010708e
80101a78:	e8 03 e9 ff ff       	call   80100380 <panic>
80101a7d:	8d 76 00             	lea    0x0(%esi),%esi

80101a80 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101a80:	55                   	push   %ebp
80101a81:	89 e5                	mov    %esp,%ebp
80101a83:	8b 55 08             	mov    0x8(%ebp),%edx
80101a86:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101a89:	8b 0a                	mov    (%edx),%ecx
80101a8b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101a8e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101a91:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101a94:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101a98:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101a9b:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101a9f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101aa3:	8b 52 58             	mov    0x58(%edx),%edx
80101aa6:	89 50 10             	mov    %edx,0x10(%eax)
}
80101aa9:	5d                   	pop    %ebp
80101aaa:	c3                   	ret
80101aab:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80101ab0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ab0:	55                   	push   %ebp
80101ab1:	89 e5                	mov    %esp,%ebp
80101ab3:	57                   	push   %edi
80101ab4:	56                   	push   %esi
80101ab5:	53                   	push   %ebx
80101ab6:	83 ec 1c             	sub    $0x1c,%esp
80101ab9:	8b 75 08             	mov    0x8(%ebp),%esi
80101abc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101abf:	8b 7d 10             	mov    0x10(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ac2:	66 83 7e 50 03       	cmpw   $0x3,0x50(%esi)
{
80101ac7:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101aca:	89 75 d8             	mov    %esi,-0x28(%ebp)
80101acd:	8b 45 14             	mov    0x14(%ebp),%eax
  if(ip->type == T_DEV){
80101ad0:	0f 84 aa 00 00 00    	je     80101b80 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101ad6:	8b 75 d8             	mov    -0x28(%ebp),%esi
80101ad9:	8b 56 58             	mov    0x58(%esi),%edx
80101adc:	39 fa                	cmp    %edi,%edx
80101ade:	0f 82 bd 00 00 00    	jb     80101ba1 <readi+0xf1>
80101ae4:	89 f9                	mov    %edi,%ecx
80101ae6:	31 db                	xor    %ebx,%ebx
80101ae8:	01 c1                	add    %eax,%ecx
80101aea:	0f 92 c3             	setb   %bl
80101aed:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101af0:	0f 82 ab 00 00 00    	jb     80101ba1 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101af6:	89 d3                	mov    %edx,%ebx
80101af8:	29 fb                	sub    %edi,%ebx
80101afa:	39 ca                	cmp    %ecx,%edx
80101afc:	0f 42 c3             	cmovb  %ebx,%eax

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101aff:	85 c0                	test   %eax,%eax
80101b01:	74 73                	je     80101b76 <readi+0xc6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
80101b03:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80101b06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101b09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101b10:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101b13:	89 fa                	mov    %edi,%edx
80101b15:	c1 ea 09             	shr    $0x9,%edx
80101b18:	89 d8                	mov    %ebx,%eax
80101b1a:	e8 51 f9 ff ff       	call   80101470 <bmap>
80101b1f:	83 ec 08             	sub    $0x8,%esp
80101b22:	50                   	push   %eax
80101b23:	ff 33                	push   (%ebx)
80101b25:	e8 a6 e5 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101b2a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101b2d:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101b32:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101b34:	89 f8                	mov    %edi,%eax
80101b36:	25 ff 01 00 00       	and    $0x1ff,%eax
80101b3b:	29 f3                	sub    %esi,%ebx
80101b3d:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101b3f:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101b43:	39 d9                	cmp    %ebx,%ecx
80101b45:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101b48:	83 c4 0c             	add    $0xc,%esp
80101b4b:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101b4c:	01 de                	add    %ebx,%esi
80101b4e:	01 df                	add    %ebx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
80101b50:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101b53:	50                   	push   %eax
80101b54:	ff 75 e0             	push   -0x20(%ebp)
80101b57:	e8 f4 2a 00 00       	call   80104650 <memmove>
    brelse(bp);
80101b5c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101b5f:	89 14 24             	mov    %edx,(%esp)
80101b62:	e8 89 e6 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101b67:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101b6a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101b6d:	83 c4 10             	add    $0x10,%esp
80101b70:	39 de                	cmp    %ebx,%esi
80101b72:	72 9c                	jb     80101b10 <readi+0x60>
80101b74:	89 d8                	mov    %ebx,%eax
  }
  return n;
}
80101b76:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b79:	5b                   	pop    %ebx
80101b7a:	5e                   	pop    %esi
80101b7b:	5f                   	pop    %edi
80101b7c:	5d                   	pop    %ebp
80101b7d:	c3                   	ret
80101b7e:	66 90                	xchg   %ax,%ax
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101b80:	0f bf 56 52          	movswl 0x52(%esi),%edx
80101b84:	66 83 fa 09          	cmp    $0x9,%dx
80101b88:	77 17                	ja     80101ba1 <readi+0xf1>
80101b8a:	8b 14 d5 c0 79 15 88 	mov    -0x77ea8640(,%edx,8),%edx
80101b91:	85 d2                	test   %edx,%edx
80101b93:	74 0c                	je     80101ba1 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101b95:	89 45 10             	mov    %eax,0x10(%ebp)
}
80101b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b9b:	5b                   	pop    %ebx
80101b9c:	5e                   	pop    %esi
80101b9d:	5f                   	pop    %edi
80101b9e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101b9f:	ff e2                	jmp    *%edx
      return -1;
80101ba1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101ba6:	eb ce                	jmp    80101b76 <readi+0xc6>
80101ba8:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80101baf:	00 

80101bb0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101bb0:	55                   	push   %ebp
80101bb1:	89 e5                	mov    %esp,%ebp
80101bb3:	57                   	push   %edi
80101bb4:	56                   	push   %esi
80101bb5:	53                   	push   %ebx
80101bb6:	83 ec 1c             	sub    $0x1c,%esp
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101bbf:	8b 75 14             	mov    0x14(%ebp),%esi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101bc2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101bc7:	89 7d dc             	mov    %edi,-0x24(%ebp)
80101bca:	89 75 e0             	mov    %esi,-0x20(%ebp)
80101bcd:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
80101bd0:	0f 84 ba 00 00 00    	je     80101c90 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101bd6:	39 78 58             	cmp    %edi,0x58(%eax)
80101bd9:	0f 82 ea 00 00 00    	jb     80101cc9 <writei+0x119>
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101bdf:	8b 75 e0             	mov    -0x20(%ebp),%esi
80101be2:	89 f2                	mov    %esi,%edx
80101be4:	01 fa                	add    %edi,%edx
80101be6:	0f 82 dd 00 00 00    	jb     80101cc9 <writei+0x119>
80101bec:	81 fa 00 18 01 00    	cmp    $0x11800,%edx
80101bf2:	0f 87 d1 00 00 00    	ja     80101cc9 <writei+0x119>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101bf8:	85 f6                	test   %esi,%esi
80101bfa:	0f 84 85 00 00 00    	je     80101c85 <writei+0xd5>
80101c00:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
80101c07:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101c0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c10:	8b 75 d8             	mov    -0x28(%ebp),%esi
80101c13:	89 fa                	mov    %edi,%edx
80101c15:	c1 ea 09             	shr    $0x9,%edx
80101c18:	89 f0                	mov    %esi,%eax
80101c1a:	e8 51 f8 ff ff       	call   80101470 <bmap>
80101c1f:	83 ec 08             	sub    $0x8,%esp
80101c22:	50                   	push   %eax
80101c23:	ff 36                	push   (%esi)
80101c25:	e8 a6 e4 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101c2a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101c2d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101c30:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c35:	89 c6                	mov    %eax,%esi
    m = min(n - tot, BSIZE - off%BSIZE);
80101c37:	89 f8                	mov    %edi,%eax
80101c39:	25 ff 01 00 00       	and    $0x1ff,%eax
80101c3e:	29 d3                	sub    %edx,%ebx
80101c40:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101c42:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101c46:	39 d9                	cmp    %ebx,%ecx
80101c48:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101c4b:	83 c4 0c             	add    $0xc,%esp
80101c4e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101c4f:	01 df                	add    %ebx,%edi
    memmove(bp->data + off%BSIZE, src, m);
80101c51:	ff 75 dc             	push   -0x24(%ebp)
80101c54:	50                   	push   %eax
80101c55:	e8 f6 29 00 00       	call   80104650 <memmove>
    log_write(bp);
80101c5a:	89 34 24             	mov    %esi,(%esp)
80101c5d:	e8 be 12 00 00       	call   80102f20 <log_write>
    brelse(bp);
80101c62:	89 34 24             	mov    %esi,(%esp)
80101c65:	e8 86 e5 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101c6a:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101c6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c70:	83 c4 10             	add    $0x10,%esp
80101c73:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101c76:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101c79:	39 d8                	cmp    %ebx,%eax
80101c7b:	72 93                	jb     80101c10 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101c7d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101c80:	39 78 58             	cmp    %edi,0x58(%eax)
80101c83:	72 33                	jb     80101cb8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101c85:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c8b:	5b                   	pop    %ebx
80101c8c:	5e                   	pop    %esi
80101c8d:	5f                   	pop    %edi
80101c8e:	5d                   	pop    %ebp
80101c8f:	c3                   	ret
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101c90:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101c94:	66 83 f8 09          	cmp    $0x9,%ax
80101c98:	77 2f                	ja     80101cc9 <writei+0x119>
80101c9a:	8b 04 c5 c4 79 15 88 	mov    -0x77ea863c(,%eax,8),%eax
80101ca1:	85 c0                	test   %eax,%eax
80101ca3:	74 24                	je     80101cc9 <writei+0x119>
    return devsw[ip->major].write(ip, src, n);
80101ca5:	89 75 10             	mov    %esi,0x10(%ebp)
}
80101ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101cab:	5b                   	pop    %ebx
80101cac:	5e                   	pop    %esi
80101cad:	5f                   	pop    %edi
80101cae:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101caf:	ff e0                	jmp    *%eax
80101cb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    iupdate(ip);
80101cb8:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101cbb:	89 78 58             	mov    %edi,0x58(%eax)
    iupdate(ip);
80101cbe:	50                   	push   %eax
80101cbf:	e8 2c fa ff ff       	call   801016f0 <iupdate>
80101cc4:	83 c4 10             	add    $0x10,%esp
80101cc7:	eb bc                	jmp    80101c85 <writei+0xd5>
      return -1;
80101cc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101cce:	eb b8                	jmp    80101c88 <writei+0xd8>

80101cd0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101cd0:	55                   	push   %ebp
80101cd1:	89 e5                	mov    %esp,%ebp
80101cd3:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101cd6:	6a 0e                	push   $0xe
80101cd8:	ff 75 0c             	push   0xc(%ebp)
80101cdb:	ff 75 08             	push   0x8(%ebp)
80101cde:	e8 dd 29 00 00       	call   801046c0 <strncmp>
}
80101ce3:	c9                   	leave
80101ce4:	c3                   	ret
80101ce5:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80101cec:	00 
80101ced:	8d 76 00             	lea    0x0(%esi),%esi

80101cf0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101cf0:	55                   	push   %ebp
80101cf1:	89 e5                	mov    %esp,%ebp
80101cf3:	57                   	push   %edi
80101cf4:	56                   	push   %esi
80101cf5:	53                   	push   %ebx
80101cf6:	83 ec 1c             	sub    $0x1c,%esp
80101cf9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101cfc:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101d01:	0f 85 85 00 00 00    	jne    80101d8c <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101d07:	8b 53 58             	mov    0x58(%ebx),%edx
80101d0a:	31 ff                	xor    %edi,%edi
80101d0c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101d0f:	85 d2                	test   %edx,%edx
80101d11:	74 3e                	je     80101d51 <dirlookup+0x61>
80101d13:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101d18:	6a 10                	push   $0x10
80101d1a:	57                   	push   %edi
80101d1b:	56                   	push   %esi
80101d1c:	53                   	push   %ebx
80101d1d:	e8 8e fd ff ff       	call   80101ab0 <readi>
80101d22:	83 c4 10             	add    $0x10,%esp
80101d25:	83 f8 10             	cmp    $0x10,%eax
80101d28:	75 55                	jne    80101d7f <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101d2a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101d2f:	74 18                	je     80101d49 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101d31:	83 ec 04             	sub    $0x4,%esp
80101d34:	8d 45 da             	lea    -0x26(%ebp),%eax
80101d37:	6a 0e                	push   $0xe
80101d39:	50                   	push   %eax
80101d3a:	ff 75 0c             	push   0xc(%ebp)
80101d3d:	e8 7e 29 00 00       	call   801046c0 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101d42:	83 c4 10             	add    $0x10,%esp
80101d45:	85 c0                	test   %eax,%eax
80101d47:	74 17                	je     80101d60 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101d49:	83 c7 10             	add    $0x10,%edi
80101d4c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101d4f:	72 c7                	jb     80101d18 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101d54:	31 c0                	xor    %eax,%eax
}
80101d56:	5b                   	pop    %ebx
80101d57:	5e                   	pop    %esi
80101d58:	5f                   	pop    %edi
80101d59:	5d                   	pop    %ebp
80101d5a:	c3                   	ret
80101d5b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
      if(poff)
80101d60:	8b 45 10             	mov    0x10(%ebp),%eax
80101d63:	85 c0                	test   %eax,%eax
80101d65:	74 05                	je     80101d6c <dirlookup+0x7c>
        *poff = off;
80101d67:	8b 45 10             	mov    0x10(%ebp),%eax
80101d6a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101d6c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101d70:	8b 03                	mov    (%ebx),%eax
80101d72:	e8 79 f5 ff ff       	call   801012f0 <iget>
}
80101d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d7a:	5b                   	pop    %ebx
80101d7b:	5e                   	pop    %esi
80101d7c:	5f                   	pop    %edi
80101d7d:	5d                   	pop    %ebp
80101d7e:	c3                   	ret
      panic("dirlookup read");
80101d7f:	83 ec 0c             	sub    $0xc,%esp
80101d82:	68 a8 70 10 80       	push   $0x801070a8
80101d87:	e8 f4 e5 ff ff       	call   80100380 <panic>
    panic("dirlookup not DIR");
80101d8c:	83 ec 0c             	sub    $0xc,%esp
80101d8f:	68 96 70 10 80       	push   $0x80107096
80101d94:	e8 e7 e5 ff ff       	call   80100380 <panic>
80101d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101da0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101da0:	55                   	push   %ebp
80101da1:	89 e5                	mov    %esp,%ebp
80101da3:	57                   	push   %edi
80101da4:	56                   	push   %esi
80101da5:	53                   	push   %ebx
80101da6:	89 c3                	mov    %eax,%ebx
80101da8:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101dab:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101dae:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101db1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101db4:	0f 84 9e 01 00 00    	je     80101f58 <namex+0x1b8>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101dba:	e8 61 1b 00 00       	call   80103920 <myproc>
  acquire(&icache.lock);
80101dbf:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80101dc2:	8b 70 68             	mov    0x68(%eax),%esi
  acquire(&icache.lock);
80101dc5:	68 20 7a 15 88       	push   $0x88157a20
80101dca:	e8 d1 26 00 00       	call   801044a0 <acquire>
  ip->ref++;
80101dcf:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101dd3:	c7 04 24 20 7a 15 88 	movl   $0x88157a20,(%esp)
80101dda:	e8 81 27 00 00       	call   80104560 <release>
80101ddf:	83 c4 10             	add    $0x10,%esp
80101de2:	eb 07                	jmp    80101deb <namex+0x4b>
80101de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101de8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101deb:	0f b6 03             	movzbl (%ebx),%eax
80101dee:	3c 2f                	cmp    $0x2f,%al
80101df0:	74 f6                	je     80101de8 <namex+0x48>
  if(*path == 0)
80101df2:	84 c0                	test   %al,%al
80101df4:	0f 84 06 01 00 00    	je     80101f00 <namex+0x160>
  while(*path != '/' && *path != 0)
80101dfa:	0f b6 03             	movzbl (%ebx),%eax
80101dfd:	84 c0                	test   %al,%al
80101dff:	0f 84 10 01 00 00    	je     80101f15 <namex+0x175>
80101e05:	89 df                	mov    %ebx,%edi
80101e07:	3c 2f                	cmp    $0x2f,%al
80101e09:	0f 84 06 01 00 00    	je     80101f15 <namex+0x175>
80101e0f:	90                   	nop
80101e10:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80101e14:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80101e17:	3c 2f                	cmp    $0x2f,%al
80101e19:	74 04                	je     80101e1f <namex+0x7f>
80101e1b:	84 c0                	test   %al,%al
80101e1d:	75 f1                	jne    80101e10 <namex+0x70>
  len = path - s;
80101e1f:	89 f8                	mov    %edi,%eax
80101e21:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80101e23:	83 f8 0d             	cmp    $0xd,%eax
80101e26:	0f 8e ac 00 00 00    	jle    80101ed8 <namex+0x138>
    memmove(name, s, DIRSIZ);
80101e2c:	83 ec 04             	sub    $0x4,%esp
80101e2f:	6a 0e                	push   $0xe
80101e31:	53                   	push   %ebx
80101e32:	89 fb                	mov    %edi,%ebx
80101e34:	ff 75 e4             	push   -0x1c(%ebp)
80101e37:	e8 14 28 00 00       	call   80104650 <memmove>
80101e3c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101e3f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101e42:	75 0c                	jne    80101e50 <namex+0xb0>
80101e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101e48:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101e4b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101e4e:	74 f8                	je     80101e48 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101e50:	83 ec 0c             	sub    $0xc,%esp
80101e53:	56                   	push   %esi
80101e54:	e8 47 f9 ff ff       	call   801017a0 <ilock>
    if(ip->type != T_DIR){
80101e59:	83 c4 10             	add    $0x10,%esp
80101e5c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101e61:	0f 85 b7 00 00 00    	jne    80101f1e <namex+0x17e>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101e67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101e6a:	85 c0                	test   %eax,%eax
80101e6c:	74 09                	je     80101e77 <namex+0xd7>
80101e6e:	80 3b 00             	cmpb   $0x0,(%ebx)
80101e71:	0f 84 f7 00 00 00    	je     80101f6e <namex+0x1ce>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101e77:	83 ec 04             	sub    $0x4,%esp
80101e7a:	6a 00                	push   $0x0
80101e7c:	ff 75 e4             	push   -0x1c(%ebp)
80101e7f:	56                   	push   %esi
80101e80:	e8 6b fe ff ff       	call   80101cf0 <dirlookup>
80101e85:	83 c4 10             	add    $0x10,%esp
80101e88:	89 c7                	mov    %eax,%edi
80101e8a:	85 c0                	test   %eax,%eax
80101e8c:	0f 84 8c 00 00 00    	je     80101f1e <namex+0x17e>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101e92:	83 ec 0c             	sub    $0xc,%esp
80101e95:	8d 4e 0c             	lea    0xc(%esi),%ecx
80101e98:	51                   	push   %ecx
80101e99:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101e9c:	e8 4f 24 00 00       	call   801042f0 <holdingsleep>
80101ea1:	83 c4 10             	add    $0x10,%esp
80101ea4:	85 c0                	test   %eax,%eax
80101ea6:	0f 84 02 01 00 00    	je     80101fae <namex+0x20e>
80101eac:	8b 56 08             	mov    0x8(%esi),%edx
80101eaf:	85 d2                	test   %edx,%edx
80101eb1:	0f 8e f7 00 00 00    	jle    80101fae <namex+0x20e>
  releasesleep(&ip->lock);
80101eb7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80101eba:	83 ec 0c             	sub    $0xc,%esp
80101ebd:	51                   	push   %ecx
80101ebe:	e8 ed 23 00 00       	call   801042b0 <releasesleep>
  iput(ip);
80101ec3:	89 34 24             	mov    %esi,(%esp)
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
    ip = next;
80101ec6:	89 fe                	mov    %edi,%esi
  iput(ip);
80101ec8:	e8 03 fa ff ff       	call   801018d0 <iput>
80101ecd:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101ed0:	e9 16 ff ff ff       	jmp    80101deb <namex+0x4b>
80101ed5:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80101ed8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101edb:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
    memmove(name, s, len);
80101ede:	83 ec 04             	sub    $0x4,%esp
80101ee1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101ee4:	50                   	push   %eax
80101ee5:	53                   	push   %ebx
    name[len] = 0;
80101ee6:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80101ee8:	ff 75 e4             	push   -0x1c(%ebp)
80101eeb:	e8 60 27 00 00       	call   80104650 <memmove>
    name[len] = 0;
80101ef0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80101ef3:	83 c4 10             	add    $0x10,%esp
80101ef6:	c6 01 00             	movb   $0x0,(%ecx)
80101ef9:	e9 41 ff ff ff       	jmp    80101e3f <namex+0x9f>
80101efe:	66 90                	xchg   %ax,%ax
  }
  if(nameiparent){
80101f00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101f03:	85 c0                	test   %eax,%eax
80101f05:	0f 85 93 00 00 00    	jne    80101f9e <namex+0x1fe>
    iput(ip);
    return 0;
  }
  return ip;
}
80101f0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f0e:	89 f0                	mov    %esi,%eax
80101f10:	5b                   	pop    %ebx
80101f11:	5e                   	pop    %esi
80101f12:	5f                   	pop    %edi
80101f13:	5d                   	pop    %ebp
80101f14:	c3                   	ret
  while(*path != '/' && *path != 0)
80101f15:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101f18:	89 df                	mov    %ebx,%edi
80101f1a:	31 c0                	xor    %eax,%eax
80101f1c:	eb c0                	jmp    80101ede <namex+0x13e>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f1e:	83 ec 0c             	sub    $0xc,%esp
80101f21:	8d 5e 0c             	lea    0xc(%esi),%ebx
80101f24:	53                   	push   %ebx
80101f25:	e8 c6 23 00 00       	call   801042f0 <holdingsleep>
80101f2a:	83 c4 10             	add    $0x10,%esp
80101f2d:	85 c0                	test   %eax,%eax
80101f2f:	74 7d                	je     80101fae <namex+0x20e>
80101f31:	8b 4e 08             	mov    0x8(%esi),%ecx
80101f34:	85 c9                	test   %ecx,%ecx
80101f36:	7e 76                	jle    80101fae <namex+0x20e>
  releasesleep(&ip->lock);
80101f38:	83 ec 0c             	sub    $0xc,%esp
80101f3b:	53                   	push   %ebx
80101f3c:	e8 6f 23 00 00       	call   801042b0 <releasesleep>
  iput(ip);
80101f41:	89 34 24             	mov    %esi,(%esp)
      return 0;
80101f44:	31 f6                	xor    %esi,%esi
  iput(ip);
80101f46:	e8 85 f9 ff ff       	call   801018d0 <iput>
      return 0;
80101f4b:	83 c4 10             	add    $0x10,%esp
}
80101f4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f51:	89 f0                	mov    %esi,%eax
80101f53:	5b                   	pop    %ebx
80101f54:	5e                   	pop    %esi
80101f55:	5f                   	pop    %edi
80101f56:	5d                   	pop    %ebp
80101f57:	c3                   	ret
    ip = iget(ROOTDEV, ROOTINO);
80101f58:	ba 01 00 00 00       	mov    $0x1,%edx
80101f5d:	b8 01 00 00 00       	mov    $0x1,%eax
80101f62:	e8 89 f3 ff ff       	call   801012f0 <iget>
80101f67:	89 c6                	mov    %eax,%esi
80101f69:	e9 7d fe ff ff       	jmp    80101deb <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f6e:	83 ec 0c             	sub    $0xc,%esp
80101f71:	8d 5e 0c             	lea    0xc(%esi),%ebx
80101f74:	53                   	push   %ebx
80101f75:	e8 76 23 00 00       	call   801042f0 <holdingsleep>
80101f7a:	83 c4 10             	add    $0x10,%esp
80101f7d:	85 c0                	test   %eax,%eax
80101f7f:	74 2d                	je     80101fae <namex+0x20e>
80101f81:	8b 7e 08             	mov    0x8(%esi),%edi
80101f84:	85 ff                	test   %edi,%edi
80101f86:	7e 26                	jle    80101fae <namex+0x20e>
  releasesleep(&ip->lock);
80101f88:	83 ec 0c             	sub    $0xc,%esp
80101f8b:	53                   	push   %ebx
80101f8c:	e8 1f 23 00 00       	call   801042b0 <releasesleep>
}
80101f91:	83 c4 10             	add    $0x10,%esp
}
80101f94:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f97:	89 f0                	mov    %esi,%eax
80101f99:	5b                   	pop    %ebx
80101f9a:	5e                   	pop    %esi
80101f9b:	5f                   	pop    %edi
80101f9c:	5d                   	pop    %ebp
80101f9d:	c3                   	ret
    iput(ip);
80101f9e:	83 ec 0c             	sub    $0xc,%esp
80101fa1:	56                   	push   %esi
      return 0;
80101fa2:	31 f6                	xor    %esi,%esi
    iput(ip);
80101fa4:	e8 27 f9 ff ff       	call   801018d0 <iput>
    return 0;
80101fa9:	83 c4 10             	add    $0x10,%esp
80101fac:	eb a0                	jmp    80101f4e <namex+0x1ae>
    panic("iunlock");
80101fae:	83 ec 0c             	sub    $0xc,%esp
80101fb1:	68 8e 70 10 80       	push   $0x8010708e
80101fb6:	e8 c5 e3 ff ff       	call   80100380 <panic>
80101fbb:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80101fc0 <dirlink>:
{
80101fc0:	55                   	push   %ebp
80101fc1:	89 e5                	mov    %esp,%ebp
80101fc3:	57                   	push   %edi
80101fc4:	56                   	push   %esi
80101fc5:	53                   	push   %ebx
80101fc6:	83 ec 20             	sub    $0x20,%esp
80101fc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80101fcc:	6a 00                	push   $0x0
80101fce:	ff 75 0c             	push   0xc(%ebp)
80101fd1:	53                   	push   %ebx
80101fd2:	e8 19 fd ff ff       	call   80101cf0 <dirlookup>
80101fd7:	83 c4 10             	add    $0x10,%esp
80101fda:	85 c0                	test   %eax,%eax
80101fdc:	75 67                	jne    80102045 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101fde:	8b 7b 58             	mov    0x58(%ebx),%edi
80101fe1:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101fe4:	85 ff                	test   %edi,%edi
80101fe6:	74 29                	je     80102011 <dirlink+0x51>
80101fe8:	31 ff                	xor    %edi,%edi
80101fea:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101fed:	eb 09                	jmp    80101ff8 <dirlink+0x38>
80101fef:	90                   	nop
80101ff0:	83 c7 10             	add    $0x10,%edi
80101ff3:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101ff6:	73 19                	jae    80102011 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101ff8:	6a 10                	push   $0x10
80101ffa:	57                   	push   %edi
80101ffb:	56                   	push   %esi
80101ffc:	53                   	push   %ebx
80101ffd:	e8 ae fa ff ff       	call   80101ab0 <readi>
80102002:	83 c4 10             	add    $0x10,%esp
80102005:	83 f8 10             	cmp    $0x10,%eax
80102008:	75 4e                	jne    80102058 <dirlink+0x98>
    if(de.inum == 0)
8010200a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010200f:	75 df                	jne    80101ff0 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102011:	83 ec 04             	sub    $0x4,%esp
80102014:	8d 45 da             	lea    -0x26(%ebp),%eax
80102017:	6a 0e                	push   $0xe
80102019:	ff 75 0c             	push   0xc(%ebp)
8010201c:	50                   	push   %eax
8010201d:	e8 ee 26 00 00       	call   80104710 <strncpy>
  de.inum = inum;
80102022:	8b 45 10             	mov    0x10(%ebp),%eax
80102025:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102029:	6a 10                	push   $0x10
8010202b:	57                   	push   %edi
8010202c:	56                   	push   %esi
8010202d:	53                   	push   %ebx
8010202e:	e8 7d fb ff ff       	call   80101bb0 <writei>
80102033:	83 c4 20             	add    $0x20,%esp
80102036:	83 f8 10             	cmp    $0x10,%eax
80102039:	75 2a                	jne    80102065 <dirlink+0xa5>
  return 0;
8010203b:	31 c0                	xor    %eax,%eax
}
8010203d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102040:	5b                   	pop    %ebx
80102041:	5e                   	pop    %esi
80102042:	5f                   	pop    %edi
80102043:	5d                   	pop    %ebp
80102044:	c3                   	ret
    iput(ip);
80102045:	83 ec 0c             	sub    $0xc,%esp
80102048:	50                   	push   %eax
80102049:	e8 82 f8 ff ff       	call   801018d0 <iput>
    return -1;
8010204e:	83 c4 10             	add    $0x10,%esp
80102051:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102056:	eb e5                	jmp    8010203d <dirlink+0x7d>
      panic("dirlink read");
80102058:	83 ec 0c             	sub    $0xc,%esp
8010205b:	68 b7 70 10 80       	push   $0x801070b7
80102060:	e8 1b e3 ff ff       	call   80100380 <panic>
    panic("dirlink");
80102065:	83 ec 0c             	sub    $0xc,%esp
80102068:	68 13 73 10 80       	push   $0x80107313
8010206d:	e8 0e e3 ff ff       	call   80100380 <panic>
80102072:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80102079:	00 
8010207a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102080 <namei>:

struct inode*
namei(char *path)
{
80102080:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102081:	31 d2                	xor    %edx,%edx
{
80102083:	89 e5                	mov    %esp,%ebp
80102085:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
80102088:	8b 45 08             	mov    0x8(%ebp),%eax
8010208b:	8d 4d ea             	lea    -0x16(%ebp),%ecx
8010208e:	e8 0d fd ff ff       	call   80101da0 <namex>
}
80102093:	c9                   	leave
80102094:	c3                   	ret
80102095:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010209c:	00 
8010209d:	8d 76 00             	lea    0x0(%esi),%esi

801020a0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801020a0:	55                   	push   %ebp
  return namex(path, 1, name);
801020a1:	ba 01 00 00 00       	mov    $0x1,%edx
{
801020a6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
801020a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801020ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
801020ae:	5d                   	pop    %ebp
  return namex(path, 1, name);
801020af:	e9 ec fc ff ff       	jmp    80101da0 <namex>
801020b4:	66 90                	xchg   %ax,%ax
801020b6:	66 90                	xchg   %ax,%ax
801020b8:	66 90                	xchg   %ax,%ax
801020ba:	66 90                	xchg   %ax,%ax
801020bc:	66 90                	xchg   %ax,%ax
801020be:	66 90                	xchg   %ax,%ax

801020c0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801020c0:	55                   	push   %ebp
801020c1:	89 e5                	mov    %esp,%ebp
801020c3:	57                   	push   %edi
801020c4:	56                   	push   %esi
801020c5:	53                   	push   %ebx
801020c6:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
801020c9:	85 c0                	test   %eax,%eax
801020cb:	0f 84 b4 00 00 00    	je     80102185 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
801020d1:	8b 70 08             	mov    0x8(%eax),%esi
801020d4:	89 c3                	mov    %eax,%ebx
801020d6:	81 fe e7 03 00 00    	cmp    $0x3e7,%esi
801020dc:	0f 87 96 00 00 00    	ja     80102178 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801020e2:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
801020e7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801020ee:	00 
801020ef:	90                   	nop
801020f0:	89 ca                	mov    %ecx,%edx
801020f2:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801020f3:	83 e0 c0             	and    $0xffffffc0,%eax
801020f6:	3c 40                	cmp    $0x40,%al
801020f8:	75 f6                	jne    801020f0 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801020fa:	31 ff                	xor    %edi,%edi
801020fc:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102101:	89 f8                	mov    %edi,%eax
80102103:	ee                   	out    %al,(%dx)
80102104:	b8 01 00 00 00       	mov    $0x1,%eax
80102109:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010210e:	ee                   	out    %al,(%dx)
8010210f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102114:	89 f0                	mov    %esi,%eax
80102116:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102117:	89 f0                	mov    %esi,%eax
80102119:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010211e:	c1 f8 08             	sar    $0x8,%eax
80102121:	ee                   	out    %al,(%dx)
80102122:	ba f5 01 00 00       	mov    $0x1f5,%edx
80102127:	89 f8                	mov    %edi,%eax
80102129:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010212a:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
8010212e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102133:	c1 e0 04             	shl    $0x4,%eax
80102136:	83 e0 10             	and    $0x10,%eax
80102139:	83 c8 e0             	or     $0xffffffe0,%eax
8010213c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
8010213d:	f6 03 04             	testb  $0x4,(%ebx)
80102140:	75 16                	jne    80102158 <idestart+0x98>
80102142:	b8 20 00 00 00       	mov    $0x20,%eax
80102147:	89 ca                	mov    %ecx,%edx
80102149:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010214a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010214d:	5b                   	pop    %ebx
8010214e:	5e                   	pop    %esi
8010214f:	5f                   	pop    %edi
80102150:	5d                   	pop    %ebp
80102151:	c3                   	ret
80102152:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102158:	b8 30 00 00 00       	mov    $0x30,%eax
8010215d:	89 ca                	mov    %ecx,%edx
8010215f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
80102160:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
80102165:	8d 73 5c             	lea    0x5c(%ebx),%esi
80102168:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010216d:	fc                   	cld
8010216e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
80102170:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102173:	5b                   	pop    %ebx
80102174:	5e                   	pop    %esi
80102175:	5f                   	pop    %edi
80102176:	5d                   	pop    %ebp
80102177:	c3                   	ret
    panic("incorrect blockno");
80102178:	83 ec 0c             	sub    $0xc,%esp
8010217b:	68 cd 70 10 80       	push   $0x801070cd
80102180:	e8 fb e1 ff ff       	call   80100380 <panic>
    panic("idestart");
80102185:	83 ec 0c             	sub    $0xc,%esp
80102188:	68 c4 70 10 80       	push   $0x801070c4
8010218d:	e8 ee e1 ff ff       	call   80100380 <panic>
80102192:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80102199:	00 
8010219a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801021a0 <ideinit>:
{
801021a0:	55                   	push   %ebp
801021a1:	89 e5                	mov    %esp,%ebp
801021a3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
801021a6:	68 df 70 10 80       	push   $0x801070df
801021ab:	68 c0 96 15 88       	push   $0x881596c0
801021b0:	e8 8b 21 00 00       	call   80104340 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801021b5:	58                   	pop    %eax
801021b6:	a1 e0 ad 15 88       	mov    0x8815ade0,%eax
801021bb:	5a                   	pop    %edx
801021bc:	83 e8 01             	sub    $0x1,%eax
801021bf:	50                   	push   %eax
801021c0:	6a 0e                	push   $0xe
801021c2:	e8 99 02 00 00       	call   80102460 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801021c7:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021ca:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
801021cf:	90                   	nop
801021d0:	89 ca                	mov    %ecx,%edx
801021d2:	ec                   	in     (%dx),%al
801021d3:	83 e0 c0             	and    $0xffffffc0,%eax
801021d6:	3c 40                	cmp    $0x40,%al
801021d8:	75 f6                	jne    801021d0 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801021da:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
801021df:	ba f6 01 00 00       	mov    $0x1f6,%edx
801021e4:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021e5:	89 ca                	mov    %ecx,%edx
801021e7:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
801021e8:	84 c0                	test   %al,%al
801021ea:	75 1e                	jne    8010220a <ideinit+0x6a>
801021ec:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
801021f1:	ba f7 01 00 00       	mov    $0x1f7,%edx
801021f6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801021fd:	00 
801021fe:	66 90                	xchg   %ax,%ax
  for(i=0; i<1000; i++){
80102200:	83 e9 01             	sub    $0x1,%ecx
80102203:	74 0f                	je     80102214 <ideinit+0x74>
80102205:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102206:	84 c0                	test   %al,%al
80102208:	74 f6                	je     80102200 <ideinit+0x60>
      havedisk1 = 1;
8010220a:	c7 05 a0 96 15 88 01 	movl   $0x1,0x881596a0
80102211:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102214:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102219:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010221e:	ee                   	out    %al,(%dx)
}
8010221f:	c9                   	leave
80102220:	c3                   	ret
80102221:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80102228:	00 
80102229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102230 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102230:	55                   	push   %ebp
80102231:	89 e5                	mov    %esp,%ebp
80102233:	57                   	push   %edi
80102234:	56                   	push   %esi
80102235:	53                   	push   %ebx
80102236:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102239:	68 c0 96 15 88       	push   $0x881596c0
8010223e:	e8 5d 22 00 00       	call   801044a0 <acquire>

  if((b = idequeue) == 0){
80102243:	8b 1d a4 96 15 88    	mov    0x881596a4,%ebx
80102249:	83 c4 10             	add    $0x10,%esp
8010224c:	85 db                	test   %ebx,%ebx
8010224e:	74 63                	je     801022b3 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102250:	8b 43 58             	mov    0x58(%ebx),%eax
80102253:	a3 a4 96 15 88       	mov    %eax,0x881596a4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102258:	8b 33                	mov    (%ebx),%esi
8010225a:	f7 c6 04 00 00 00    	test   $0x4,%esi
80102260:	75 2f                	jne    80102291 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102262:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102267:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010226e:	00 
8010226f:	90                   	nop
80102270:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102271:	89 c1                	mov    %eax,%ecx
80102273:	83 e1 c0             	and    $0xffffffc0,%ecx
80102276:	80 f9 40             	cmp    $0x40,%cl
80102279:	75 f5                	jne    80102270 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010227b:	a8 21                	test   $0x21,%al
8010227d:	75 12                	jne    80102291 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
8010227f:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80102282:	b9 80 00 00 00       	mov    $0x80,%ecx
80102287:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010228c:	fc                   	cld
8010228d:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010228f:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
80102291:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
80102294:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
80102297:	83 ce 02             	or     $0x2,%esi
8010229a:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
8010229c:	53                   	push   %ebx
8010229d:	e8 ce 1d 00 00       	call   80104070 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801022a2:	a1 a4 96 15 88       	mov    0x881596a4,%eax
801022a7:	83 c4 10             	add    $0x10,%esp
801022aa:	85 c0                	test   %eax,%eax
801022ac:	74 05                	je     801022b3 <ideintr+0x83>
    idestart(idequeue);
801022ae:	e8 0d fe ff ff       	call   801020c0 <idestart>
    release(&idelock);
801022b3:	83 ec 0c             	sub    $0xc,%esp
801022b6:	68 c0 96 15 88       	push   $0x881596c0
801022bb:	e8 a0 22 00 00       	call   80104560 <release>

  release(&idelock);
}
801022c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022c3:	5b                   	pop    %ebx
801022c4:	5e                   	pop    %esi
801022c5:	5f                   	pop    %edi
801022c6:	5d                   	pop    %ebp
801022c7:	c3                   	ret
801022c8:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801022cf:	00 

801022d0 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801022d0:	55                   	push   %ebp
801022d1:	89 e5                	mov    %esp,%ebp
801022d3:	53                   	push   %ebx
801022d4:	83 ec 10             	sub    $0x10,%esp
801022d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801022da:	8d 43 0c             	lea    0xc(%ebx),%eax
801022dd:	50                   	push   %eax
801022de:	e8 0d 20 00 00       	call   801042f0 <holdingsleep>
801022e3:	83 c4 10             	add    $0x10,%esp
801022e6:	85 c0                	test   %eax,%eax
801022e8:	0f 84 c3 00 00 00    	je     801023b1 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801022ee:	8b 03                	mov    (%ebx),%eax
801022f0:	83 e0 06             	and    $0x6,%eax
801022f3:	83 f8 02             	cmp    $0x2,%eax
801022f6:	0f 84 a8 00 00 00    	je     801023a4 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
801022fc:	8b 53 04             	mov    0x4(%ebx),%edx
801022ff:	85 d2                	test   %edx,%edx
80102301:	74 0d                	je     80102310 <iderw+0x40>
80102303:	a1 a0 96 15 88       	mov    0x881596a0,%eax
80102308:	85 c0                	test   %eax,%eax
8010230a:	0f 84 87 00 00 00    	je     80102397 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102310:	83 ec 0c             	sub    $0xc,%esp
80102313:	68 c0 96 15 88       	push   $0x881596c0
80102318:	e8 83 21 00 00       	call   801044a0 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010231d:	a1 a4 96 15 88       	mov    0x881596a4,%eax
  b->qnext = 0;
80102322:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102329:	83 c4 10             	add    $0x10,%esp
8010232c:	85 c0                	test   %eax,%eax
8010232e:	74 60                	je     80102390 <iderw+0xc0>
80102330:	89 c2                	mov    %eax,%edx
80102332:	8b 40 58             	mov    0x58(%eax),%eax
80102335:	85 c0                	test   %eax,%eax
80102337:	75 f7                	jne    80102330 <iderw+0x60>
80102339:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
8010233c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010233e:	39 1d a4 96 15 88    	cmp    %ebx,0x881596a4
80102344:	74 3a                	je     80102380 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102346:	8b 03                	mov    (%ebx),%eax
80102348:	83 e0 06             	and    $0x6,%eax
8010234b:	83 f8 02             	cmp    $0x2,%eax
8010234e:	74 1b                	je     8010236b <iderw+0x9b>
    sleep(b, &idelock);
80102350:	83 ec 08             	sub    $0x8,%esp
80102353:	68 c0 96 15 88       	push   $0x881596c0
80102358:	53                   	push   %ebx
80102359:	e8 62 1b 00 00       	call   80103ec0 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010235e:	8b 03                	mov    (%ebx),%eax
80102360:	83 c4 10             	add    $0x10,%esp
80102363:	83 e0 06             	and    $0x6,%eax
80102366:	83 f8 02             	cmp    $0x2,%eax
80102369:	75 e5                	jne    80102350 <iderw+0x80>
  }


  release(&idelock);
8010236b:	c7 45 08 c0 96 15 88 	movl   $0x881596c0,0x8(%ebp)
}
80102372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102375:	c9                   	leave
  release(&idelock);
80102376:	e9 e5 21 00 00       	jmp    80104560 <release>
8010237b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
    idestart(b);
80102380:	89 d8                	mov    %ebx,%eax
80102382:	e8 39 fd ff ff       	call   801020c0 <idestart>
80102387:	eb bd                	jmp    80102346 <iderw+0x76>
80102389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102390:	ba a4 96 15 88       	mov    $0x881596a4,%edx
80102395:	eb a5                	jmp    8010233c <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
80102397:	83 ec 0c             	sub    $0xc,%esp
8010239a:	68 0e 71 10 80       	push   $0x8010710e
8010239f:	e8 dc df ff ff       	call   80100380 <panic>
    panic("iderw: nothing to do");
801023a4:	83 ec 0c             	sub    $0xc,%esp
801023a7:	68 f9 70 10 80       	push   $0x801070f9
801023ac:	e8 cf df ff ff       	call   80100380 <panic>
    panic("iderw: buf not locked");
801023b1:	83 ec 0c             	sub    $0xc,%esp
801023b4:	68 e3 70 10 80       	push   $0x801070e3
801023b9:	e8 c2 df ff ff       	call   80100380 <panic>
801023be:	66 90                	xchg   %ax,%ax

801023c0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
801023c0:	55                   	push   %ebp
801023c1:	89 e5                	mov    %esp,%ebp
801023c3:	56                   	push   %esi
801023c4:	53                   	push   %ebx
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801023c5:	c7 05 f4 96 15 88 00 	movl   $0xfec00000,0x881596f4
801023cc:	00 c0 fe 
  ioapic->reg = reg;
801023cf:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
801023d6:	00 00 00 
  return ioapic->data;
801023d9:	8b 15 f4 96 15 88    	mov    0x881596f4,%edx
801023df:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
801023e2:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
801023e8:	8b 1d f4 96 15 88    	mov    0x881596f4,%ebx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
801023ee:	0f b6 15 40 a8 15 88 	movzbl 0x8815a840,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801023f5:	c1 ee 10             	shr    $0x10,%esi
801023f8:	89 f0                	mov    %esi,%eax
801023fa:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
801023fd:	8b 43 10             	mov    0x10(%ebx),%eax
  id = ioapicread(REG_ID) >> 24;
80102400:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102403:	39 c2                	cmp    %eax,%edx
80102405:	74 16                	je     8010241d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102407:	83 ec 0c             	sub    $0xc,%esp
8010240a:	68 c8 74 10 80       	push   $0x801074c8
8010240f:	e8 9c e2 ff ff       	call   801006b0 <cprintf>
  ioapic->reg = reg;
80102414:	8b 1d f4 96 15 88    	mov    0x881596f4,%ebx
8010241a:	83 c4 10             	add    $0x10,%esp
{
8010241d:	ba 10 00 00 00       	mov    $0x10,%edx
80102422:	31 c0                	xor    %eax,%eax
80102424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  ioapic->reg = reg;
80102428:	89 13                	mov    %edx,(%ebx)
8010242a:	8d 48 20             	lea    0x20(%eax),%ecx
  ioapic->data = data;
8010242d:	8b 1d f4 96 15 88    	mov    0x881596f4,%ebx

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102433:	83 c0 01             	add    $0x1,%eax
80102436:	81 c9 00 00 01 00    	or     $0x10000,%ecx
  ioapic->data = data;
8010243c:	89 4b 10             	mov    %ecx,0x10(%ebx)
  ioapic->reg = reg;
8010243f:	8d 4a 01             	lea    0x1(%edx),%ecx
  for(i = 0; i <= maxintr; i++){
80102442:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
80102445:	89 0b                	mov    %ecx,(%ebx)
  ioapic->data = data;
80102447:	8b 1d f4 96 15 88    	mov    0x881596f4,%ebx
8010244d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
  for(i = 0; i <= maxintr; i++){
80102454:	39 c6                	cmp    %eax,%esi
80102456:	7d d0                	jge    80102428 <ioapicinit+0x68>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102458:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010245b:	5b                   	pop    %ebx
8010245c:	5e                   	pop    %esi
8010245d:	5d                   	pop    %ebp
8010245e:	c3                   	ret
8010245f:	90                   	nop

80102460 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102460:	55                   	push   %ebp
  ioapic->reg = reg;
80102461:	8b 0d f4 96 15 88    	mov    0x881596f4,%ecx
{
80102467:	89 e5                	mov    %esp,%ebp
80102469:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010246c:	8d 50 20             	lea    0x20(%eax),%edx
8010246f:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
80102473:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102475:	8b 0d f4 96 15 88    	mov    0x881596f4,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010247b:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
8010247e:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102481:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
80102484:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102486:	a1 f4 96 15 88       	mov    0x881596f4,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010248b:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
8010248e:	89 50 10             	mov    %edx,0x10(%eax)
}
80102491:	5d                   	pop    %ebp
80102492:	c3                   	ret
80102493:	66 90                	xchg   %ax,%ax
80102495:	66 90                	xchg   %ax,%ax
80102497:	66 90                	xchg   %ax,%ax
80102499:	66 90                	xchg   %ax,%ax
8010249b:	66 90                	xchg   %ax,%ax
8010249d:	66 90                	xchg   %ax,%ax
8010249f:	90                   	nop

801024a0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801024a0:	55                   	push   %ebp
801024a1:	89 e5                	mov    %esp,%ebp
801024a3:	53                   	push   %ebx
801024a4:	83 ec 04             	sub    $0x4,%esp
801024a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801024aa:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801024b0:	75 76                	jne    80102528 <kfree+0x88>
801024b2:	81 fb 88 d5 15 88    	cmp    $0x8815d588,%ebx
801024b8:	72 6e                	jb     80102528 <kfree+0x88>
801024ba:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801024c0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801024c5:	77 61                	ja     80102528 <kfree+0x88>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801024c7:	83 ec 04             	sub    $0x4,%esp
801024ca:	68 00 10 00 00       	push   $0x1000
801024cf:	6a 01                	push   $0x1
801024d1:	53                   	push   %ebx
801024d2:	e8 d9 20 00 00       	call   801045b0 <memset>

  if(kmem.use_lock)
801024d7:	8b 15 34 97 15 88    	mov    0x88159734,%edx
801024dd:	83 c4 10             	add    $0x10,%esp
801024e0:	85 d2                	test   %edx,%edx
801024e2:	75 1c                	jne    80102500 <kfree+0x60>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
801024e4:	a1 38 97 15 88       	mov    0x88159738,%eax
801024e9:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
801024eb:	a1 34 97 15 88       	mov    0x88159734,%eax
  kmem.freelist = r;
801024f0:	89 1d 38 97 15 88    	mov    %ebx,0x88159738
  if(kmem.use_lock)
801024f6:	85 c0                	test   %eax,%eax
801024f8:	75 1e                	jne    80102518 <kfree+0x78>
    release(&kmem.lock);
}
801024fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801024fd:	c9                   	leave
801024fe:	c3                   	ret
801024ff:	90                   	nop
    acquire(&kmem.lock);
80102500:	83 ec 0c             	sub    $0xc,%esp
80102503:	68 00 97 15 88       	push   $0x88159700
80102508:	e8 93 1f 00 00       	call   801044a0 <acquire>
8010250d:	83 c4 10             	add    $0x10,%esp
80102510:	eb d2                	jmp    801024e4 <kfree+0x44>
80102512:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
80102518:	c7 45 08 00 97 15 88 	movl   $0x88159700,0x8(%ebp)
}
8010251f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102522:	c9                   	leave
    release(&kmem.lock);
80102523:	e9 38 20 00 00       	jmp    80104560 <release>
    panic("kfree");
80102528:	83 ec 0c             	sub    $0xc,%esp
8010252b:	68 2c 71 10 80       	push   $0x8010712c
80102530:	e8 4b de ff ff       	call   80100380 <panic>
80102535:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010253c:	00 
8010253d:	8d 76 00             	lea    0x0(%esi),%esi

80102540 <freerange>:
{
80102540:	55                   	push   %ebp
80102541:	89 e5                	mov    %esp,%ebp
80102543:	56                   	push   %esi
80102544:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102545:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102548:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010254b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102551:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102557:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010255d:	39 de                	cmp    %ebx,%esi
8010255f:	72 23                	jb     80102584 <freerange+0x44>
80102561:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102568:	83 ec 0c             	sub    $0xc,%esp
8010256b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102571:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102577:	50                   	push   %eax
80102578:	e8 23 ff ff ff       	call   801024a0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010257d:	83 c4 10             	add    $0x10,%esp
80102580:	39 de                	cmp    %ebx,%esi
80102582:	73 e4                	jae    80102568 <freerange+0x28>
}
80102584:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102587:	5b                   	pop    %ebx
80102588:	5e                   	pop    %esi
80102589:	5d                   	pop    %ebp
8010258a:	c3                   	ret
8010258b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80102590 <kinit2>:
{
80102590:	55                   	push   %ebp
80102591:	89 e5                	mov    %esp,%ebp
80102593:	56                   	push   %esi
80102594:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102595:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102598:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010259b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801025a1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025a7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801025ad:	39 de                	cmp    %ebx,%esi
801025af:	72 23                	jb     801025d4 <kinit2+0x44>
801025b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801025b8:	83 ec 0c             	sub    $0xc,%esp
801025bb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025c1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801025c7:	50                   	push   %eax
801025c8:	e8 d3 fe ff ff       	call   801024a0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025cd:	83 c4 10             	add    $0x10,%esp
801025d0:	39 de                	cmp    %ebx,%esi
801025d2:	73 e4                	jae    801025b8 <kinit2+0x28>
  kmem.use_lock = 1;
801025d4:	c7 05 34 97 15 88 01 	movl   $0x1,0x88159734
801025db:	00 00 00 
}
801025de:	8d 65 f8             	lea    -0x8(%ebp),%esp
801025e1:	5b                   	pop    %ebx
801025e2:	5e                   	pop    %esi
801025e3:	5d                   	pop    %ebp
801025e4:	c3                   	ret
801025e5:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801025ec:	00 
801025ed:	8d 76 00             	lea    0x0(%esi),%esi

801025f0 <kinit1>:
{
801025f0:	55                   	push   %ebp
801025f1:	89 e5                	mov    %esp,%ebp
801025f3:	56                   	push   %esi
801025f4:	53                   	push   %ebx
801025f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
801025f8:	83 ec 08             	sub    $0x8,%esp
801025fb:	68 32 71 10 80       	push   $0x80107132
80102600:	68 00 97 15 88       	push   $0x88159700
80102605:	e8 36 1d 00 00       	call   80104340 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010260a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010260d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102610:	c7 05 34 97 15 88 00 	movl   $0x0,0x88159734
80102617:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010261a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102620:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102626:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010262c:	39 de                	cmp    %ebx,%esi
8010262e:	72 1c                	jb     8010264c <kinit1+0x5c>
    kfree(p);
80102630:	83 ec 0c             	sub    $0xc,%esp
80102633:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102639:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010263f:	50                   	push   %eax
80102640:	e8 5b fe ff ff       	call   801024a0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102645:	83 c4 10             	add    $0x10,%esp
80102648:	39 de                	cmp    %ebx,%esi
8010264a:	73 e4                	jae    80102630 <kinit1+0x40>
}
8010264c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010264f:	5b                   	pop    %ebx
80102650:	5e                   	pop    %esi
80102651:	5d                   	pop    %ebp
80102652:	c3                   	ret
80102653:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010265a:	00 
8010265b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80102660 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102660:	55                   	push   %ebp
80102661:	89 e5                	mov    %esp,%ebp
80102663:	53                   	push   %ebx
80102664:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
80102667:	a1 34 97 15 88       	mov    0x88159734,%eax
8010266c:	85 c0                	test   %eax,%eax
8010266e:	75 20                	jne    80102690 <kalloc+0x30>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102670:	8b 1d 38 97 15 88    	mov    0x88159738,%ebx
  if(r)
80102676:	85 db                	test   %ebx,%ebx
80102678:	74 07                	je     80102681 <kalloc+0x21>
    kmem.freelist = r->next;
8010267a:	8b 03                	mov    (%ebx),%eax
8010267c:	a3 38 97 15 88       	mov    %eax,0x88159738
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}
80102681:	89 d8                	mov    %ebx,%eax
80102683:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102686:	c9                   	leave
80102687:	c3                   	ret
80102688:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010268f:	00 
    acquire(&kmem.lock);
80102690:	83 ec 0c             	sub    $0xc,%esp
80102693:	68 00 97 15 88       	push   $0x88159700
80102698:	e8 03 1e 00 00       	call   801044a0 <acquire>
  r = kmem.freelist;
8010269d:	8b 1d 38 97 15 88    	mov    0x88159738,%ebx
  if(kmem.use_lock)
801026a3:	a1 34 97 15 88       	mov    0x88159734,%eax
  if(r)
801026a8:	83 c4 10             	add    $0x10,%esp
801026ab:	85 db                	test   %ebx,%ebx
801026ad:	74 08                	je     801026b7 <kalloc+0x57>
    kmem.freelist = r->next;
801026af:	8b 13                	mov    (%ebx),%edx
801026b1:	89 15 38 97 15 88    	mov    %edx,0x88159738
  if(kmem.use_lock)
801026b7:	85 c0                	test   %eax,%eax
801026b9:	74 c6                	je     80102681 <kalloc+0x21>
    release(&kmem.lock);
801026bb:	83 ec 0c             	sub    $0xc,%esp
801026be:	68 00 97 15 88       	push   $0x88159700
801026c3:	e8 98 1e 00 00       	call   80104560 <release>
}
801026c8:	89 d8                	mov    %ebx,%eax
    release(&kmem.lock);
801026ca:	83 c4 10             	add    $0x10,%esp
}
801026cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026d0:	c9                   	leave
801026d1:	c3                   	ret
801026d2:	66 90                	xchg   %ax,%ax
801026d4:	66 90                	xchg   %ax,%ax
801026d6:	66 90                	xchg   %ax,%ax
801026d8:	66 90                	xchg   %ax,%ax
801026da:	66 90                	xchg   %ax,%ax
801026dc:	66 90                	xchg   %ax,%ax
801026de:	66 90                	xchg   %ax,%ax

801026e0 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026e0:	ba 64 00 00 00       	mov    $0x64,%edx
801026e5:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801026e6:	a8 01                	test   $0x1,%al
801026e8:	0f 84 c2 00 00 00    	je     801027b0 <kbdgetc+0xd0>
{
801026ee:	55                   	push   %ebp
801026ef:	ba 60 00 00 00       	mov    $0x60,%edx
801026f4:	89 e5                	mov    %esp,%ebp
801026f6:	53                   	push   %ebx
801026f7:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
801026f8:	8b 1d 3c 97 15 88    	mov    0x8815973c,%ebx
  data = inb(KBDATAP);
801026fe:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
80102701:	3c e0                	cmp    $0xe0,%al
80102703:	74 5b                	je     80102760 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102705:	89 da                	mov    %ebx,%edx
80102707:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
8010270a:	84 c0                	test   %al,%al
8010270c:	78 62                	js     80102770 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010270e:	85 d2                	test   %edx,%edx
80102710:	74 09                	je     8010271b <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102712:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
80102715:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
80102718:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
8010271b:	0f b6 91 40 77 10 80 	movzbl -0x7fef88c0(%ecx),%edx
  shift ^= togglecode[data];
80102722:	0f b6 81 40 76 10 80 	movzbl -0x7fef89c0(%ecx),%eax
  shift |= shiftcode[data];
80102729:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
8010272b:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010272d:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
8010272f:	89 15 3c 97 15 88    	mov    %edx,0x8815973c
  c = charcode[shift & (CTL | SHIFT)][data];
80102735:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102738:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010273b:	8b 04 85 20 76 10 80 	mov    -0x7fef89e0(,%eax,4),%eax
80102742:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102746:	74 0b                	je     80102753 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
80102748:	8d 50 9f             	lea    -0x61(%eax),%edx
8010274b:	83 fa 19             	cmp    $0x19,%edx
8010274e:	77 48                	ja     80102798 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102750:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102756:	c9                   	leave
80102757:	c3                   	ret
80102758:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010275f:	00 
    shift |= E0ESC;
80102760:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102763:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102765:	89 1d 3c 97 15 88    	mov    %ebx,0x8815973c
}
8010276b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010276e:	c9                   	leave
8010276f:	c3                   	ret
    data = (shift & E0ESC ? data : data & 0x7F);
80102770:	83 e0 7f             	and    $0x7f,%eax
80102773:	85 d2                	test   %edx,%edx
80102775:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
80102778:	0f b6 81 40 77 10 80 	movzbl -0x7fef88c0(%ecx),%eax
8010277f:	83 c8 40             	or     $0x40,%eax
80102782:	0f b6 c0             	movzbl %al,%eax
80102785:	f7 d0                	not    %eax
80102787:	21 d8                	and    %ebx,%eax
80102789:	a3 3c 97 15 88       	mov    %eax,0x8815973c
    return 0;
8010278e:	31 c0                	xor    %eax,%eax
80102790:	eb d9                	jmp    8010276b <kbdgetc+0x8b>
80102792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
80102798:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
8010279b:	8d 50 20             	lea    0x20(%eax),%edx
}
8010279e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027a1:	c9                   	leave
      c += 'a' - 'A';
801027a2:	83 f9 1a             	cmp    $0x1a,%ecx
801027a5:	0f 42 c2             	cmovb  %edx,%eax
}
801027a8:	c3                   	ret
801027a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801027b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801027b5:	c3                   	ret
801027b6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801027bd:	00 
801027be:	66 90                	xchg   %ax,%ax

801027c0 <kbdintr>:

void
kbdintr(void)
{
801027c0:	55                   	push   %ebp
801027c1:	89 e5                	mov    %esp,%ebp
801027c3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801027c6:	68 e0 26 10 80       	push   $0x801026e0
801027cb:	e8 d0 e0 ff ff       	call   801008a0 <consoleintr>
}
801027d0:	83 c4 10             	add    $0x10,%esp
801027d3:	c9                   	leave
801027d4:	c3                   	ret
801027d5:	66 90                	xchg   %ax,%ax
801027d7:	66 90                	xchg   %ax,%ax
801027d9:	66 90                	xchg   %ax,%ax
801027db:	66 90                	xchg   %ax,%ax
801027dd:	66 90                	xchg   %ax,%ax
801027df:	90                   	nop

801027e0 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
801027e0:	a1 40 97 15 88       	mov    0x88159740,%eax
801027e5:	85 c0                	test   %eax,%eax
801027e7:	0f 84 c3 00 00 00    	je     801028b0 <lapicinit+0xd0>
  lapic[index] = value;
801027ed:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
801027f4:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
801027f7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801027fa:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102801:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102804:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102807:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
8010280e:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102811:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102814:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010281b:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
8010281e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102821:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
80102828:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010282b:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010282e:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102835:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102838:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010283b:	8b 50 30             	mov    0x30(%eax),%edx
8010283e:	81 e2 00 00 fc 00    	and    $0xfc0000,%edx
80102844:	75 72                	jne    801028b8 <lapicinit+0xd8>
  lapic[index] = value;
80102846:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
8010284d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102850:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102853:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010285a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010285d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102860:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102867:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010286a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010286d:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102874:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102877:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010287a:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102881:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102884:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102887:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
8010288e:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102891:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102894:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102898:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
8010289e:	80 e6 10             	and    $0x10,%dh
801028a1:	75 f5                	jne    80102898 <lapicinit+0xb8>
  lapic[index] = value;
801028a3:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801028aa:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801028ad:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801028b0:	c3                   	ret
801028b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
801028b8:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
801028bf:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801028c2:	8b 50 20             	mov    0x20(%eax),%edx
}
801028c5:	e9 7c ff ff ff       	jmp    80102846 <lapicinit+0x66>
801028ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801028d0 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
801028d0:	a1 40 97 15 88       	mov    0x88159740,%eax
801028d5:	85 c0                	test   %eax,%eax
801028d7:	74 07                	je     801028e0 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
801028d9:	8b 40 20             	mov    0x20(%eax),%eax
801028dc:	c1 e8 18             	shr    $0x18,%eax
801028df:	c3                   	ret
    return 0;
801028e0:	31 c0                	xor    %eax,%eax
}
801028e2:	c3                   	ret
801028e3:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801028ea:	00 
801028eb:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

801028f0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
801028f0:	a1 40 97 15 88       	mov    0x88159740,%eax
801028f5:	85 c0                	test   %eax,%eax
801028f7:	74 0d                	je     80102906 <lapiceoi+0x16>
  lapic[index] = value;
801028f9:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102900:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102903:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102906:	c3                   	ret
80102907:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010290e:	00 
8010290f:	90                   	nop

80102910 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102910:	c3                   	ret
80102911:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80102918:	00 
80102919:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102920 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102920:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102921:	b8 0f 00 00 00       	mov    $0xf,%eax
80102926:	ba 70 00 00 00       	mov    $0x70,%edx
8010292b:	89 e5                	mov    %esp,%ebp
8010292d:	53                   	push   %ebx
8010292e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102931:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102934:	ee                   	out    %al,(%dx)
80102935:	b8 0a 00 00 00       	mov    $0xa,%eax
8010293a:	ba 71 00 00 00       	mov    $0x71,%edx
8010293f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102940:	31 c0                	xor    %eax,%eax
  lapic[index] = value;
80102942:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102945:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
8010294b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
8010294d:	c1 e9 0c             	shr    $0xc,%ecx
  lapic[index] = value;
80102950:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102952:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102955:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102958:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
8010295e:	a1 40 97 15 88       	mov    0x88159740,%eax
80102963:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102969:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010296c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102973:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102976:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102979:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102980:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102983:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102986:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010298c:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010298f:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102995:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102998:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010299e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029a1:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029a7:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
801029aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029ad:	c9                   	leave
801029ae:	c3                   	ret
801029af:	90                   	nop

801029b0 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801029b0:	55                   	push   %ebp
801029b1:	b8 0b 00 00 00       	mov    $0xb,%eax
801029b6:	ba 70 00 00 00       	mov    $0x70,%edx
801029bb:	89 e5                	mov    %esp,%ebp
801029bd:	57                   	push   %edi
801029be:	56                   	push   %esi
801029bf:	53                   	push   %ebx
801029c0:	83 ec 4c             	sub    $0x4c,%esp
801029c3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029c4:	ba 71 00 00 00       	mov    $0x71,%edx
801029c9:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
801029ca:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029cd:	bf 70 00 00 00       	mov    $0x70,%edi
801029d2:	88 45 b3             	mov    %al,-0x4d(%ebp)
801029d5:	8d 76 00             	lea    0x0(%esi),%esi
801029d8:	31 c0                	xor    %eax,%eax
801029da:	89 fa                	mov    %edi,%edx
801029dc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029dd:	b9 71 00 00 00       	mov    $0x71,%ecx
801029e2:	89 ca                	mov    %ecx,%edx
801029e4:	ec                   	in     (%dx),%al
801029e5:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029e8:	89 fa                	mov    %edi,%edx
801029ea:	b8 02 00 00 00       	mov    $0x2,%eax
801029ef:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029f0:	89 ca                	mov    %ecx,%edx
801029f2:	ec                   	in     (%dx),%al
801029f3:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029f6:	89 fa                	mov    %edi,%edx
801029f8:	b8 04 00 00 00       	mov    $0x4,%eax
801029fd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029fe:	89 ca                	mov    %ecx,%edx
80102a00:	ec                   	in     (%dx),%al
80102a01:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a04:	89 fa                	mov    %edi,%edx
80102a06:	b8 07 00 00 00       	mov    $0x7,%eax
80102a0b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a0c:	89 ca                	mov    %ecx,%edx
80102a0e:	ec                   	in     (%dx),%al
80102a0f:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a12:	89 fa                	mov    %edi,%edx
80102a14:	b8 08 00 00 00       	mov    $0x8,%eax
80102a19:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a1a:	89 ca                	mov    %ecx,%edx
80102a1c:	ec                   	in     (%dx),%al
80102a1d:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a1f:	89 fa                	mov    %edi,%edx
80102a21:	b8 09 00 00 00       	mov    $0x9,%eax
80102a26:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a27:	89 ca                	mov    %ecx,%edx
80102a29:	ec                   	in     (%dx),%al
80102a2a:	0f b6 d8             	movzbl %al,%ebx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a2d:	89 fa                	mov    %edi,%edx
80102a2f:	b8 0a 00 00 00       	mov    $0xa,%eax
80102a34:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a35:	89 ca                	mov    %ecx,%edx
80102a37:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102a38:	84 c0                	test   %al,%al
80102a3a:	78 9c                	js     801029d8 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102a3c:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102a40:	89 f2                	mov    %esi,%edx
80102a42:	89 5d cc             	mov    %ebx,-0x34(%ebp)
80102a45:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a48:	89 fa                	mov    %edi,%edx
80102a4a:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102a4d:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102a51:	89 75 c8             	mov    %esi,-0x38(%ebp)
80102a54:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102a57:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102a5b:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102a5e:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102a62:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102a65:	31 c0                	xor    %eax,%eax
80102a67:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a68:	89 ca                	mov    %ecx,%edx
80102a6a:	ec                   	in     (%dx),%al
80102a6b:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a6e:	89 fa                	mov    %edi,%edx
80102a70:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102a73:	b8 02 00 00 00       	mov    $0x2,%eax
80102a78:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a79:	89 ca                	mov    %ecx,%edx
80102a7b:	ec                   	in     (%dx),%al
80102a7c:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a7f:	89 fa                	mov    %edi,%edx
80102a81:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102a84:	b8 04 00 00 00       	mov    $0x4,%eax
80102a89:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a8a:	89 ca                	mov    %ecx,%edx
80102a8c:	ec                   	in     (%dx),%al
80102a8d:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a90:	89 fa                	mov    %edi,%edx
80102a92:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102a95:	b8 07 00 00 00       	mov    $0x7,%eax
80102a9a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a9b:	89 ca                	mov    %ecx,%edx
80102a9d:	ec                   	in     (%dx),%al
80102a9e:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aa1:	89 fa                	mov    %edi,%edx
80102aa3:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102aa6:	b8 08 00 00 00       	mov    $0x8,%eax
80102aab:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102aac:	89 ca                	mov    %ecx,%edx
80102aae:	ec                   	in     (%dx),%al
80102aaf:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ab2:	89 fa                	mov    %edi,%edx
80102ab4:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102ab7:	b8 09 00 00 00       	mov    $0x9,%eax
80102abc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102abd:	89 ca                	mov    %ecx,%edx
80102abf:	ec                   	in     (%dx),%al
80102ac0:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102ac3:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102ac6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102ac9:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102acc:	6a 18                	push   $0x18
80102ace:	50                   	push   %eax
80102acf:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102ad2:	50                   	push   %eax
80102ad3:	e8 28 1b 00 00       	call   80104600 <memcmp>
80102ad8:	83 c4 10             	add    $0x10,%esp
80102adb:	85 c0                	test   %eax,%eax
80102add:	0f 85 f5 fe ff ff    	jne    801029d8 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102ae3:	0f b6 75 b3          	movzbl -0x4d(%ebp),%esi
80102ae7:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102aea:	89 f0                	mov    %esi,%eax
80102aec:	84 c0                	test   %al,%al
80102aee:	75 78                	jne    80102b68 <cmostime+0x1b8>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102af0:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102af3:	89 c2                	mov    %eax,%edx
80102af5:	83 e0 0f             	and    $0xf,%eax
80102af8:	c1 ea 04             	shr    $0x4,%edx
80102afb:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102afe:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b01:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102b04:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102b07:	89 c2                	mov    %eax,%edx
80102b09:	83 e0 0f             	and    $0xf,%eax
80102b0c:	c1 ea 04             	shr    $0x4,%edx
80102b0f:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b12:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b15:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102b18:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102b1b:	89 c2                	mov    %eax,%edx
80102b1d:	83 e0 0f             	and    $0xf,%eax
80102b20:	c1 ea 04             	shr    $0x4,%edx
80102b23:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b26:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b29:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102b2c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102b2f:	89 c2                	mov    %eax,%edx
80102b31:	83 e0 0f             	and    $0xf,%eax
80102b34:	c1 ea 04             	shr    $0x4,%edx
80102b37:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b3a:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b3d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102b40:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102b43:	89 c2                	mov    %eax,%edx
80102b45:	83 e0 0f             	and    $0xf,%eax
80102b48:	c1 ea 04             	shr    $0x4,%edx
80102b4b:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b4e:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b51:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102b54:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102b57:	89 c2                	mov    %eax,%edx
80102b59:	83 e0 0f             	and    $0xf,%eax
80102b5c:	c1 ea 04             	shr    $0x4,%edx
80102b5f:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b62:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b65:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102b68:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102b6b:	89 03                	mov    %eax,(%ebx)
80102b6d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102b70:	89 43 04             	mov    %eax,0x4(%ebx)
80102b73:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102b76:	89 43 08             	mov    %eax,0x8(%ebx)
80102b79:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102b7c:	89 43 0c             	mov    %eax,0xc(%ebx)
80102b7f:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102b82:	89 43 10             	mov    %eax,0x10(%ebx)
80102b85:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102b88:	89 43 14             	mov    %eax,0x14(%ebx)
  r->year += 2000;
80102b8b:	81 43 14 d0 07 00 00 	addl   $0x7d0,0x14(%ebx)
}
80102b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102b95:	5b                   	pop    %ebx
80102b96:	5e                   	pop    %esi
80102b97:	5f                   	pop    %edi
80102b98:	5d                   	pop    %ebp
80102b99:	c3                   	ret
80102b9a:	66 90                	xchg   %ax,%ax
80102b9c:	66 90                	xchg   %ax,%ax
80102b9e:	66 90                	xchg   %ax,%ax

80102ba0 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102ba0:	8b 0d a8 97 15 88    	mov    0x881597a8,%ecx
80102ba6:	85 c9                	test   %ecx,%ecx
80102ba8:	0f 8e 8a 00 00 00    	jle    80102c38 <install_trans+0x98>
{
80102bae:	55                   	push   %ebp
80102baf:	89 e5                	mov    %esp,%ebp
80102bb1:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102bb2:	31 ff                	xor    %edi,%edi
{
80102bb4:	56                   	push   %esi
80102bb5:	53                   	push   %ebx
80102bb6:	83 ec 0c             	sub    $0xc,%esp
80102bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102bc0:	a1 94 97 15 88       	mov    0x88159794,%eax
80102bc5:	83 ec 08             	sub    $0x8,%esp
80102bc8:	01 f8                	add    %edi,%eax
80102bca:	83 c0 01             	add    $0x1,%eax
80102bcd:	50                   	push   %eax
80102bce:	ff 35 a4 97 15 88    	push   0x881597a4
80102bd4:	e8 f7 d4 ff ff       	call   801000d0 <bread>
80102bd9:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102bdb:	58                   	pop    %eax
80102bdc:	5a                   	pop    %edx
80102bdd:	ff 34 bd ac 97 15 88 	push   -0x77ea6854(,%edi,4)
80102be4:	ff 35 a4 97 15 88    	push   0x881597a4
  for (tail = 0; tail < log.lh.n; tail++) {
80102bea:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102bed:	e8 de d4 ff ff       	call   801000d0 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102bf2:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102bf5:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102bf7:	8d 46 5c             	lea    0x5c(%esi),%eax
80102bfa:	68 00 02 00 00       	push   $0x200
80102bff:	50                   	push   %eax
80102c00:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102c03:	50                   	push   %eax
80102c04:	e8 47 1a 00 00       	call   80104650 <memmove>
    bwrite(dbuf);  // write dst to disk
80102c09:	89 1c 24             	mov    %ebx,(%esp)
80102c0c:	e8 9f d5 ff ff       	call   801001b0 <bwrite>
    brelse(lbuf);
80102c11:	89 34 24             	mov    %esi,(%esp)
80102c14:	e8 d7 d5 ff ff       	call   801001f0 <brelse>
    brelse(dbuf);
80102c19:	89 1c 24             	mov    %ebx,(%esp)
80102c1c:	e8 cf d5 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102c21:	83 c4 10             	add    $0x10,%esp
80102c24:	39 3d a8 97 15 88    	cmp    %edi,0x881597a8
80102c2a:	7f 94                	jg     80102bc0 <install_trans+0x20>
  }
}
80102c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c2f:	5b                   	pop    %ebx
80102c30:	5e                   	pop    %esi
80102c31:	5f                   	pop    %edi
80102c32:	5d                   	pop    %ebp
80102c33:	c3                   	ret
80102c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102c38:	c3                   	ret
80102c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102c40 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102c40:	55                   	push   %ebp
80102c41:	89 e5                	mov    %esp,%ebp
80102c43:	53                   	push   %ebx
80102c44:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102c47:	ff 35 94 97 15 88    	push   0x88159794
80102c4d:	ff 35 a4 97 15 88    	push   0x881597a4
80102c53:	e8 78 d4 ff ff       	call   801000d0 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102c58:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102c5b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102c5d:	a1 a8 97 15 88       	mov    0x881597a8,%eax
80102c62:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102c65:	85 c0                	test   %eax,%eax
80102c67:	7e 19                	jle    80102c82 <write_head+0x42>
80102c69:	31 d2                	xor    %edx,%edx
80102c6b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
    hb->block[i] = log.lh.block[i];
80102c70:	8b 0c 95 ac 97 15 88 	mov    -0x77ea6854(,%edx,4),%ecx
80102c77:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102c7b:	83 c2 01             	add    $0x1,%edx
80102c7e:	39 d0                	cmp    %edx,%eax
80102c80:	75 ee                	jne    80102c70 <write_head+0x30>
  }
  bwrite(buf);
80102c82:	83 ec 0c             	sub    $0xc,%esp
80102c85:	53                   	push   %ebx
80102c86:	e8 25 d5 ff ff       	call   801001b0 <bwrite>
  brelse(buf);
80102c8b:	89 1c 24             	mov    %ebx,(%esp)
80102c8e:	e8 5d d5 ff ff       	call   801001f0 <brelse>
}
80102c93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102c96:	83 c4 10             	add    $0x10,%esp
80102c99:	c9                   	leave
80102c9a:	c3                   	ret
80102c9b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80102ca0 <initlog>:
{
80102ca0:	55                   	push   %ebp
80102ca1:	89 e5                	mov    %esp,%ebp
80102ca3:	53                   	push   %ebx
80102ca4:	83 ec 2c             	sub    $0x2c,%esp
80102ca7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102caa:	68 37 71 10 80       	push   $0x80107137
80102caf:	68 60 97 15 88       	push   $0x88159760
80102cb4:	e8 87 16 00 00       	call   80104340 <initlock>
  readsb(dev, &sb);
80102cb9:	58                   	pop    %eax
80102cba:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102cbd:	5a                   	pop    %edx
80102cbe:	50                   	push   %eax
80102cbf:	53                   	push   %ebx
80102cc0:	e8 7b e8 ff ff       	call   80101540 <readsb>
  log.start = sb.logstart;
80102cc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102cc8:	59                   	pop    %ecx
  log.dev = dev;
80102cc9:	89 1d a4 97 15 88    	mov    %ebx,0x881597a4
  log.size = sb.nlog;
80102ccf:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102cd2:	a3 94 97 15 88       	mov    %eax,0x88159794
  log.size = sb.nlog;
80102cd7:	89 15 98 97 15 88    	mov    %edx,0x88159798
  struct buf *buf = bread(log.dev, log.start);
80102cdd:	5a                   	pop    %edx
80102cde:	50                   	push   %eax
80102cdf:	53                   	push   %ebx
80102ce0:	e8 eb d3 ff ff       	call   801000d0 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102ce5:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102ce8:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102ceb:	89 1d a8 97 15 88    	mov    %ebx,0x881597a8
  for (i = 0; i < log.lh.n; i++) {
80102cf1:	85 db                	test   %ebx,%ebx
80102cf3:	7e 1d                	jle    80102d12 <initlog+0x72>
80102cf5:	31 d2                	xor    %edx,%edx
80102cf7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80102cfe:	00 
80102cff:	90                   	nop
    log.lh.block[i] = lh->block[i];
80102d00:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102d04:	89 0c 95 ac 97 15 88 	mov    %ecx,-0x77ea6854(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102d0b:	83 c2 01             	add    $0x1,%edx
80102d0e:	39 d3                	cmp    %edx,%ebx
80102d10:	75 ee                	jne    80102d00 <initlog+0x60>
  brelse(buf);
80102d12:	83 ec 0c             	sub    $0xc,%esp
80102d15:	50                   	push   %eax
80102d16:	e8 d5 d4 ff ff       	call   801001f0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102d1b:	e8 80 fe ff ff       	call   80102ba0 <install_trans>
  log.lh.n = 0;
80102d20:	c7 05 a8 97 15 88 00 	movl   $0x0,0x881597a8
80102d27:	00 00 00 
  write_head(); // clear the log
80102d2a:	e8 11 ff ff ff       	call   80102c40 <write_head>
}
80102d2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102d32:	83 c4 10             	add    $0x10,%esp
80102d35:	c9                   	leave
80102d36:	c3                   	ret
80102d37:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80102d3e:	00 
80102d3f:	90                   	nop

80102d40 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102d40:	55                   	push   %ebp
80102d41:	89 e5                	mov    %esp,%ebp
80102d43:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102d46:	68 60 97 15 88       	push   $0x88159760
80102d4b:	e8 50 17 00 00       	call   801044a0 <acquire>
80102d50:	83 c4 10             	add    $0x10,%esp
80102d53:	eb 18                	jmp    80102d6d <begin_op+0x2d>
80102d55:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102d58:	83 ec 08             	sub    $0x8,%esp
80102d5b:	68 60 97 15 88       	push   $0x88159760
80102d60:	68 60 97 15 88       	push   $0x88159760
80102d65:	e8 56 11 00 00       	call   80103ec0 <sleep>
80102d6a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102d6d:	a1 a0 97 15 88       	mov    0x881597a0,%eax
80102d72:	85 c0                	test   %eax,%eax
80102d74:	75 e2                	jne    80102d58 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102d76:	a1 9c 97 15 88       	mov    0x8815979c,%eax
80102d7b:	8b 15 a8 97 15 88    	mov    0x881597a8,%edx
80102d81:	83 c0 01             	add    $0x1,%eax
80102d84:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102d87:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102d8a:	83 fa 1e             	cmp    $0x1e,%edx
80102d8d:	7f c9                	jg     80102d58 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102d8f:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102d92:	a3 9c 97 15 88       	mov    %eax,0x8815979c
      release(&log.lock);
80102d97:	68 60 97 15 88       	push   $0x88159760
80102d9c:	e8 bf 17 00 00       	call   80104560 <release>
      break;
    }
  }
}
80102da1:	83 c4 10             	add    $0x10,%esp
80102da4:	c9                   	leave
80102da5:	c3                   	ret
80102da6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80102dad:	00 
80102dae:	66 90                	xchg   %ax,%ax

80102db0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102db0:	55                   	push   %ebp
80102db1:	89 e5                	mov    %esp,%ebp
80102db3:	57                   	push   %edi
80102db4:	56                   	push   %esi
80102db5:	53                   	push   %ebx
80102db6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102db9:	68 60 97 15 88       	push   $0x88159760
80102dbe:	e8 dd 16 00 00       	call   801044a0 <acquire>
  log.outstanding -= 1;
80102dc3:	a1 9c 97 15 88       	mov    0x8815979c,%eax
  if(log.committing)
80102dc8:	8b 35 a0 97 15 88    	mov    0x881597a0,%esi
80102dce:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102dd1:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102dd4:	89 1d 9c 97 15 88    	mov    %ebx,0x8815979c
  if(log.committing)
80102dda:	85 f6                	test   %esi,%esi
80102ddc:	0f 85 22 01 00 00    	jne    80102f04 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102de2:	85 db                	test   %ebx,%ebx
80102de4:	0f 85 f6 00 00 00    	jne    80102ee0 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102dea:	c7 05 a0 97 15 88 01 	movl   $0x1,0x881597a0
80102df1:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102df4:	83 ec 0c             	sub    $0xc,%esp
80102df7:	68 60 97 15 88       	push   $0x88159760
80102dfc:	e8 5f 17 00 00       	call   80104560 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102e01:	8b 0d a8 97 15 88    	mov    0x881597a8,%ecx
80102e07:	83 c4 10             	add    $0x10,%esp
80102e0a:	85 c9                	test   %ecx,%ecx
80102e0c:	7f 42                	jg     80102e50 <end_op+0xa0>
    acquire(&log.lock);
80102e0e:	83 ec 0c             	sub    $0xc,%esp
80102e11:	68 60 97 15 88       	push   $0x88159760
80102e16:	e8 85 16 00 00       	call   801044a0 <acquire>
    log.committing = 0;
80102e1b:	c7 05 a0 97 15 88 00 	movl   $0x0,0x881597a0
80102e22:	00 00 00 
    wakeup(&log);
80102e25:	c7 04 24 60 97 15 88 	movl   $0x88159760,(%esp)
80102e2c:	e8 3f 12 00 00       	call   80104070 <wakeup>
    release(&log.lock);
80102e31:	c7 04 24 60 97 15 88 	movl   $0x88159760,(%esp)
80102e38:	e8 23 17 00 00       	call   80104560 <release>
80102e3d:	83 c4 10             	add    $0x10,%esp
}
80102e40:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e43:	5b                   	pop    %ebx
80102e44:	5e                   	pop    %esi
80102e45:	5f                   	pop    %edi
80102e46:	5d                   	pop    %ebp
80102e47:	c3                   	ret
80102e48:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80102e4f:	00 
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102e50:	a1 94 97 15 88       	mov    0x88159794,%eax
80102e55:	83 ec 08             	sub    $0x8,%esp
80102e58:	01 d8                	add    %ebx,%eax
80102e5a:	83 c0 01             	add    $0x1,%eax
80102e5d:	50                   	push   %eax
80102e5e:	ff 35 a4 97 15 88    	push   0x881597a4
80102e64:	e8 67 d2 ff ff       	call   801000d0 <bread>
80102e69:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102e6b:	58                   	pop    %eax
80102e6c:	5a                   	pop    %edx
80102e6d:	ff 34 9d ac 97 15 88 	push   -0x77ea6854(,%ebx,4)
80102e74:	ff 35 a4 97 15 88    	push   0x881597a4
  for (tail = 0; tail < log.lh.n; tail++) {
80102e7a:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102e7d:	e8 4e d2 ff ff       	call   801000d0 <bread>
    memmove(to->data, from->data, BSIZE);
80102e82:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102e85:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102e87:	8d 40 5c             	lea    0x5c(%eax),%eax
80102e8a:	68 00 02 00 00       	push   $0x200
80102e8f:	50                   	push   %eax
80102e90:	8d 46 5c             	lea    0x5c(%esi),%eax
80102e93:	50                   	push   %eax
80102e94:	e8 b7 17 00 00       	call   80104650 <memmove>
    bwrite(to);  // write the log
80102e99:	89 34 24             	mov    %esi,(%esp)
80102e9c:	e8 0f d3 ff ff       	call   801001b0 <bwrite>
    brelse(from);
80102ea1:	89 3c 24             	mov    %edi,(%esp)
80102ea4:	e8 47 d3 ff ff       	call   801001f0 <brelse>
    brelse(to);
80102ea9:	89 34 24             	mov    %esi,(%esp)
80102eac:	e8 3f d3 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102eb1:	83 c4 10             	add    $0x10,%esp
80102eb4:	3b 1d a8 97 15 88    	cmp    0x881597a8,%ebx
80102eba:	7c 94                	jl     80102e50 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102ebc:	e8 7f fd ff ff       	call   80102c40 <write_head>
    install_trans(); // Now install writes to home locations
80102ec1:	e8 da fc ff ff       	call   80102ba0 <install_trans>
    log.lh.n = 0;
80102ec6:	c7 05 a8 97 15 88 00 	movl   $0x0,0x881597a8
80102ecd:	00 00 00 
    write_head();    // Erase the transaction from the log
80102ed0:	e8 6b fd ff ff       	call   80102c40 <write_head>
80102ed5:	e9 34 ff ff ff       	jmp    80102e0e <end_op+0x5e>
80102eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
80102ee0:	83 ec 0c             	sub    $0xc,%esp
80102ee3:	68 60 97 15 88       	push   $0x88159760
80102ee8:	e8 83 11 00 00       	call   80104070 <wakeup>
  release(&log.lock);
80102eed:	c7 04 24 60 97 15 88 	movl   $0x88159760,(%esp)
80102ef4:	e8 67 16 00 00       	call   80104560 <release>
80102ef9:	83 c4 10             	add    $0x10,%esp
}
80102efc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102eff:	5b                   	pop    %ebx
80102f00:	5e                   	pop    %esi
80102f01:	5f                   	pop    %edi
80102f02:	5d                   	pop    %ebp
80102f03:	c3                   	ret
    panic("log.committing");
80102f04:	83 ec 0c             	sub    $0xc,%esp
80102f07:	68 3b 71 10 80       	push   $0x8010713b
80102f0c:	e8 6f d4 ff ff       	call   80100380 <panic>
80102f11:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80102f18:	00 
80102f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102f20 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102f20:	55                   	push   %ebp
80102f21:	89 e5                	mov    %esp,%ebp
80102f23:	53                   	push   %ebx
80102f24:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102f27:	8b 15 a8 97 15 88    	mov    0x881597a8,%edx
{
80102f2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102f30:	83 fa 1d             	cmp    $0x1d,%edx
80102f33:	7f 7d                	jg     80102fb2 <log_write+0x92>
80102f35:	a1 98 97 15 88       	mov    0x88159798,%eax
80102f3a:	83 e8 01             	sub    $0x1,%eax
80102f3d:	39 c2                	cmp    %eax,%edx
80102f3f:	7d 71                	jge    80102fb2 <log_write+0x92>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102f41:	a1 9c 97 15 88       	mov    0x8815979c,%eax
80102f46:	85 c0                	test   %eax,%eax
80102f48:	7e 75                	jle    80102fbf <log_write+0x9f>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102f4a:	83 ec 0c             	sub    $0xc,%esp
80102f4d:	68 60 97 15 88       	push   $0x88159760
80102f52:	e8 49 15 00 00       	call   801044a0 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102f57:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
80102f5a:	83 c4 10             	add    $0x10,%esp
80102f5d:	31 c0                	xor    %eax,%eax
80102f5f:	8b 15 a8 97 15 88    	mov    0x881597a8,%edx
80102f65:	85 d2                	test   %edx,%edx
80102f67:	7f 0e                	jg     80102f77 <log_write+0x57>
80102f69:	eb 15                	jmp    80102f80 <log_write+0x60>
80102f6b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
80102f70:	83 c0 01             	add    $0x1,%eax
80102f73:	39 c2                	cmp    %eax,%edx
80102f75:	74 29                	je     80102fa0 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102f77:	39 0c 85 ac 97 15 88 	cmp    %ecx,-0x77ea6854(,%eax,4)
80102f7e:	75 f0                	jne    80102f70 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
80102f80:	89 0c 85 ac 97 15 88 	mov    %ecx,-0x77ea6854(,%eax,4)
  if (i == log.lh.n)
80102f87:	39 c2                	cmp    %eax,%edx
80102f89:	74 1c                	je     80102fa7 <log_write+0x87>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102f8b:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
80102f8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
80102f91:	c7 45 08 60 97 15 88 	movl   $0x88159760,0x8(%ebp)
}
80102f98:	c9                   	leave
  release(&log.lock);
80102f99:	e9 c2 15 00 00       	jmp    80104560 <release>
80102f9e:	66 90                	xchg   %ax,%ax
  log.lh.block[i] = b->blockno;
80102fa0:	89 0c 95 ac 97 15 88 	mov    %ecx,-0x77ea6854(,%edx,4)
    log.lh.n++;
80102fa7:	83 c2 01             	add    $0x1,%edx
80102faa:	89 15 a8 97 15 88    	mov    %edx,0x881597a8
80102fb0:	eb d9                	jmp    80102f8b <log_write+0x6b>
    panic("too big a transaction");
80102fb2:	83 ec 0c             	sub    $0xc,%esp
80102fb5:	68 4a 71 10 80       	push   $0x8010714a
80102fba:	e8 c1 d3 ff ff       	call   80100380 <panic>
    panic("log_write outside of trans");
80102fbf:	83 ec 0c             	sub    $0xc,%esp
80102fc2:	68 60 71 10 80       	push   $0x80107160
80102fc7:	e8 b4 d3 ff ff       	call   80100380 <panic>
80102fcc:	66 90                	xchg   %ax,%ax
80102fce:	66 90                	xchg   %ax,%ax

80102fd0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80102fd0:	55                   	push   %ebp
80102fd1:	89 e5                	mov    %esp,%ebp
80102fd3:	53                   	push   %ebx
80102fd4:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102fd7:	e8 24 09 00 00       	call   80103900 <cpuid>
80102fdc:	89 c3                	mov    %eax,%ebx
80102fde:	e8 1d 09 00 00       	call   80103900 <cpuid>
80102fe3:	83 ec 04             	sub    $0x4,%esp
80102fe6:	53                   	push   %ebx
80102fe7:	50                   	push   %eax
80102fe8:	68 7b 71 10 80       	push   $0x8010717b
80102fed:	e8 be d6 ff ff       	call   801006b0 <cprintf>
  idtinit();       // load idt register
80102ff2:	e8 d9 27 00 00       	call   801057d0 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102ff7:	e8 94 08 00 00       	call   80103890 <mycpu>
80102ffc:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102ffe:	b8 01 00 00 00       	mov    $0x1,%eax
80103003:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010300a:	e8 d1 0b 00 00       	call   80103be0 <scheduler>
8010300f:	90                   	nop

80103010 <mpenter>:
{
80103010:	55                   	push   %ebp
80103011:	89 e5                	mov    %esp,%ebp
80103013:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103016:	e8 75 38 00 00       	call   80106890 <switchkvm>
  seginit();
8010301b:	e8 e0 37 00 00       	call   80106800 <seginit>
  lapicinit();
80103020:	e8 bb f7 ff ff       	call   801027e0 <lapicinit>
  mpmain();
80103025:	e8 a6 ff ff ff       	call   80102fd0 <mpmain>
8010302a:	66 90                	xchg   %ax,%ax
8010302c:	66 90                	xchg   %ax,%ax
8010302e:	66 90                	xchg   %ax,%ax

80103030 <main>:
{
80103030:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103034:	83 e4 f0             	and    $0xfffffff0,%esp
80103037:	ff 71 fc             	push   -0x4(%ecx)
8010303a:	55                   	push   %ebp
8010303b:	89 e5                	mov    %esp,%ebp
8010303d:	53                   	push   %ebx
8010303e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010303f:	83 ec 08             	sub    $0x8,%esp
80103042:	68 00 00 40 80       	push   $0x80400000
80103047:	68 88 d5 15 88       	push   $0x8815d588
8010304c:	e8 9f f5 ff ff       	call   801025f0 <kinit1>
  kvmalloc();      // kernel page table
80103051:	e8 fa 3c 00 00       	call   80106d50 <kvmalloc>
  mpinit();        // detect other processors
80103056:	e8 85 01 00 00       	call   801031e0 <mpinit>
  lapicinit();     // interrupt controller
8010305b:	e8 80 f7 ff ff       	call   801027e0 <lapicinit>
  seginit();       // segment descriptors
80103060:	e8 9b 37 00 00       	call   80106800 <seginit>
  picinit();       // disable pic
80103065:	e8 46 03 00 00       	call   801033b0 <picinit>
  ioapicinit();    // another interrupt controller
8010306a:	e8 51 f3 ff ff       	call   801023c0 <ioapicinit>
  consoleinit();   // console hardware
8010306f:	e8 ec d9 ff ff       	call   80100a60 <consoleinit>
  uartinit();      // serial port
80103074:	e8 57 2a 00 00       	call   80105ad0 <uartinit>
  pinit();         // process table
80103079:	e8 f2 07 00 00       	call   80103870 <pinit>
  tvinit();        // trap vectors
8010307e:	e8 cd 26 00 00       	call   80105750 <tvinit>
  binit();         // buffer cache
80103083:	e8 b8 cf ff ff       	call   80100040 <binit>
  fileinit();      // file table
80103088:	e8 a3 dd ff ff       	call   80100e30 <fileinit>
  ideinit();       // disk 
8010308d:	e8 0e f1 ff ff       	call   801021a0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103092:	83 c4 0c             	add    $0xc,%esp
80103095:	68 8a 00 00 00       	push   $0x8a
8010309a:	68 3c 25 15 88       	push   $0x8815253c
8010309f:	68 00 70 00 80       	push   $0x80007000
801030a4:	e8 a7 15 00 00       	call   80104650 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801030a9:	83 c4 10             	add    $0x10,%esp
801030ac:	69 05 e0 ad 15 88 b0 	imul   $0xb0,0x8815ade0,%eax
801030b3:	00 00 00 
801030b6:	05 60 a8 15 88       	add    $0x8815a860,%eax
801030bb:	3d 60 a8 15 88       	cmp    $0x8815a860,%eax
801030c0:	76 7e                	jbe    80103140 <main+0x110>
801030c2:	bb 60 a8 15 88       	mov    $0x8815a860,%ebx
801030c7:	eb 20                	jmp    801030e9 <main+0xb9>
801030c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801030d0:	69 05 e0 ad 15 88 b0 	imul   $0xb0,0x8815ade0,%eax
801030d7:	00 00 00 
801030da:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801030e0:	05 60 a8 15 88       	add    $0x8815a860,%eax
801030e5:	39 c3                	cmp    %eax,%ebx
801030e7:	73 57                	jae    80103140 <main+0x110>
    if(c == mycpu())  // We've started already.
801030e9:	e8 a2 07 00 00       	call   80103890 <mycpu>
801030ee:	39 c3                	cmp    %eax,%ebx
801030f0:	74 de                	je     801030d0 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801030f2:	e8 69 f5 ff ff       	call   80102660 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
801030f7:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
801030fa:	c7 05 f8 6f 00 80 10 	movl   $0x80103010,0x80006ff8
80103101:	30 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103104:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
8010310b:	90 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
8010310e:	05 00 10 00 00       	add    $0x1000,%eax
80103113:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
80103118:	0f b6 03             	movzbl (%ebx),%eax
8010311b:	68 00 70 00 00       	push   $0x7000
80103120:	50                   	push   %eax
80103121:	e8 fa f7 ff ff       	call   80102920 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103126:	83 c4 10             	add    $0x10,%esp
80103129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103130:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103136:	85 c0                	test   %eax,%eax
80103138:	74 f6                	je     80103130 <main+0x100>
8010313a:	eb 94                	jmp    801030d0 <main+0xa0>
8010313c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103140:	83 ec 08             	sub    $0x8,%esp
80103143:	68 00 00 00 8e       	push   $0x8e000000
80103148:	68 00 00 40 80       	push   $0x80400000
8010314d:	e8 3e f4 ff ff       	call   80102590 <kinit2>
  userinit();      // first user process
80103152:	e8 f9 07 00 00       	call   80103950 <userinit>
  mpmain();        // finish this processor's setup
80103157:	e8 74 fe ff ff       	call   80102fd0 <mpmain>
8010315c:	66 90                	xchg   %ax,%ax
8010315e:	66 90                	xchg   %ax,%ax

80103160 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103160:	55                   	push   %ebp
80103161:	89 e5                	mov    %esp,%ebp
80103163:	57                   	push   %edi
80103164:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103165:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010316b:	53                   	push   %ebx
  e = addr+len;
8010316c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010316f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
80103172:	39 de                	cmp    %ebx,%esi
80103174:	72 10                	jb     80103186 <mpsearch1+0x26>
80103176:	eb 50                	jmp    801031c8 <mpsearch1+0x68>
80103178:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010317f:	00 
80103180:	89 fe                	mov    %edi,%esi
80103182:	39 fb                	cmp    %edi,%ebx
80103184:	76 42                	jbe    801031c8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103186:	83 ec 04             	sub    $0x4,%esp
80103189:	8d 7e 10             	lea    0x10(%esi),%edi
8010318c:	6a 04                	push   $0x4
8010318e:	68 8f 71 10 80       	push   $0x8010718f
80103193:	56                   	push   %esi
80103194:	e8 67 14 00 00       	call   80104600 <memcmp>
80103199:	83 c4 10             	add    $0x10,%esp
8010319c:	85 c0                	test   %eax,%eax
8010319e:	75 e0                	jne    80103180 <mpsearch1+0x20>
801031a0:	89 f2                	mov    %esi,%edx
801031a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801031a8:	0f b6 0a             	movzbl (%edx),%ecx
801031ab:	83 c2 01             	add    $0x1,%edx
801031ae:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801031b0:	39 fa                	cmp    %edi,%edx
801031b2:	75 f4                	jne    801031a8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801031b4:	84 c0                	test   %al,%al
801031b6:	75 c8                	jne    80103180 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801031b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031bb:	89 f0                	mov    %esi,%eax
801031bd:	5b                   	pop    %ebx
801031be:	5e                   	pop    %esi
801031bf:	5f                   	pop    %edi
801031c0:	5d                   	pop    %ebp
801031c1:	c3                   	ret
801031c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801031c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801031cb:	31 f6                	xor    %esi,%esi
}
801031cd:	5b                   	pop    %ebx
801031ce:	89 f0                	mov    %esi,%eax
801031d0:	5e                   	pop    %esi
801031d1:	5f                   	pop    %edi
801031d2:	5d                   	pop    %ebp
801031d3:	c3                   	ret
801031d4:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801031db:	00 
801031dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801031e0 <mpinit>:
  return conf;
}

void
mpinit(void)
{
801031e0:	55                   	push   %ebp
801031e1:	89 e5                	mov    %esp,%ebp
801031e3:	57                   	push   %edi
801031e4:	56                   	push   %esi
801031e5:	53                   	push   %ebx
801031e6:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
801031e9:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
801031f0:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
801031f7:	c1 e0 08             	shl    $0x8,%eax
801031fa:	09 d0                	or     %edx,%eax
801031fc:	c1 e0 04             	shl    $0x4,%eax
801031ff:	75 1b                	jne    8010321c <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103201:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80103208:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
8010320f:	c1 e0 08             	shl    $0x8,%eax
80103212:	09 d0                	or     %edx,%eax
80103214:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103217:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010321c:	ba 00 04 00 00       	mov    $0x400,%edx
80103221:	e8 3a ff ff ff       	call   80103160 <mpsearch1>
80103226:	89 c6                	mov    %eax,%esi
80103228:	85 c0                	test   %eax,%eax
8010322a:	0f 84 40 01 00 00    	je     80103370 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103230:	8b 5e 04             	mov    0x4(%esi),%ebx
80103233:	85 db                	test   %ebx,%ebx
80103235:	0f 84 55 01 00 00    	je     80103390 <mpinit+0x1b0>
  if(memcmp(conf, "PCMP", 4) != 0)
8010323b:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010323e:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103244:	6a 04                	push   $0x4
80103246:	68 94 71 10 80       	push   $0x80107194
8010324b:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010324c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010324f:	e8 ac 13 00 00       	call   80104600 <memcmp>
80103254:	83 c4 10             	add    $0x10,%esp
80103257:	85 c0                	test   %eax,%eax
80103259:	0f 85 31 01 00 00    	jne    80103390 <mpinit+0x1b0>
  if(conf->version != 1 && conf->version != 4)
8010325f:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80103266:	3c 01                	cmp    $0x1,%al
80103268:	74 08                	je     80103272 <mpinit+0x92>
8010326a:	3c 04                	cmp    $0x4,%al
8010326c:	0f 85 1e 01 00 00    	jne    80103390 <mpinit+0x1b0>
  if(sum((uchar*)conf, conf->length) != 0)
80103272:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
  for(i=0; i<len; i++)
80103279:	66 85 d2             	test   %dx,%dx
8010327c:	74 22                	je     801032a0 <mpinit+0xc0>
8010327e:	8d 3c 1a             	lea    (%edx,%ebx,1),%edi
80103281:	89 d8                	mov    %ebx,%eax
  sum = 0;
80103283:	31 d2                	xor    %edx,%edx
80103285:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
80103288:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
8010328f:	83 c0 01             	add    $0x1,%eax
80103292:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
80103294:	39 f8                	cmp    %edi,%eax
80103296:	75 f0                	jne    80103288 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
80103298:	84 d2                	test   %dl,%dl
8010329a:	0f 85 f0 00 00 00    	jne    80103390 <mpinit+0x1b0>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
801032a0:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
801032a6:	a3 40 97 15 88       	mov    %eax,0x88159740
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801032ab:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
801032b1:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
  ismp = 1;
801032b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801032bd:	03 55 e4             	add    -0x1c(%ebp),%edx
801032c0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801032c3:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
801032c8:	39 c2                	cmp    %eax,%edx
801032ca:	76 15                	jbe    801032e1 <mpinit+0x101>
    switch(*p){
801032cc:	0f b6 08             	movzbl (%eax),%ecx
801032cf:	80 f9 02             	cmp    $0x2,%cl
801032d2:	74 54                	je     80103328 <mpinit+0x148>
801032d4:	77 3a                	ja     80103310 <mpinit+0x130>
801032d6:	84 c9                	test   %cl,%cl
801032d8:	74 66                	je     80103340 <mpinit+0x160>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
801032da:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801032dd:	39 c2                	cmp    %eax,%edx
801032df:	77 eb                	ja     801032cc <mpinit+0xec>
801032e1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
801032e4:	85 db                	test   %ebx,%ebx
801032e6:	0f 84 b1 00 00 00    	je     8010339d <mpinit+0x1bd>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
801032ec:	80 7e 0c 00          	cmpb   $0x0,0xc(%esi)
801032f0:	74 15                	je     80103307 <mpinit+0x127>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801032f2:	b8 70 00 00 00       	mov    $0x70,%eax
801032f7:	ba 22 00 00 00       	mov    $0x22,%edx
801032fc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801032fd:	ba 23 00 00 00       	mov    $0x23,%edx
80103302:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103303:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103306:	ee                   	out    %al,(%dx)
  }
}
80103307:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010330a:	5b                   	pop    %ebx
8010330b:	5e                   	pop    %esi
8010330c:	5f                   	pop    %edi
8010330d:	5d                   	pop    %ebp
8010330e:	c3                   	ret
8010330f:	90                   	nop
    switch(*p){
80103310:	83 e9 03             	sub    $0x3,%ecx
80103313:	80 f9 01             	cmp    $0x1,%cl
80103316:	76 c2                	jbe    801032da <mpinit+0xfa>
80103318:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010331f:	eb a7                	jmp    801032c8 <mpinit+0xe8>
80103321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103328:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
8010332c:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
8010332f:	88 0d 40 a8 15 88    	mov    %cl,0x8815a840
      continue;
80103335:	eb 91                	jmp    801032c8 <mpinit+0xe8>
80103337:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010333e:	00 
8010333f:	90                   	nop
      if(ncpu < NCPU) {
80103340:	8b 0d e0 ad 15 88    	mov    0x8815ade0,%ecx
80103346:	83 f9 07             	cmp    $0x7,%ecx
80103349:	7f 19                	jg     80103364 <mpinit+0x184>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010334b:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
80103351:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103355:	83 c1 01             	add    $0x1,%ecx
80103358:	89 0d e0 ad 15 88    	mov    %ecx,0x8815ade0
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010335e:	88 9f 60 a8 15 88    	mov    %bl,-0x77ea57a0(%edi)
      p += sizeof(struct mpproc);
80103364:	83 c0 14             	add    $0x14,%eax
      continue;
80103367:	e9 5c ff ff ff       	jmp    801032c8 <mpinit+0xe8>
8010336c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return mpsearch1(0xF0000, 0x10000);
80103370:	ba 00 00 01 00       	mov    $0x10000,%edx
80103375:	b8 00 00 0f 00       	mov    $0xf0000,%eax
8010337a:	e8 e1 fd ff ff       	call   80103160 <mpsearch1>
8010337f:	89 c6                	mov    %eax,%esi
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103381:	85 c0                	test   %eax,%eax
80103383:	0f 85 a7 fe ff ff    	jne    80103230 <mpinit+0x50>
80103389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
80103390:	83 ec 0c             	sub    $0xc,%esp
80103393:	68 99 71 10 80       	push   $0x80107199
80103398:	e8 e3 cf ff ff       	call   80100380 <panic>
    panic("Didn't find a suitable machine");
8010339d:	83 ec 0c             	sub    $0xc,%esp
801033a0:	68 fc 74 10 80       	push   $0x801074fc
801033a5:	e8 d6 cf ff ff       	call   80100380 <panic>
801033aa:	66 90                	xchg   %ax,%ax
801033ac:	66 90                	xchg   %ax,%ax
801033ae:	66 90                	xchg   %ax,%ax

801033b0 <picinit>:
801033b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033b5:	ba 21 00 00 00       	mov    $0x21,%edx
801033ba:	ee                   	out    %al,(%dx)
801033bb:	ba a1 00 00 00       	mov    $0xa1,%edx
801033c0:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
801033c1:	c3                   	ret
801033c2:	66 90                	xchg   %ax,%ax
801033c4:	66 90                	xchg   %ax,%ax
801033c6:	66 90                	xchg   %ax,%ax
801033c8:	66 90                	xchg   %ax,%ax
801033ca:	66 90                	xchg   %ax,%ax
801033cc:	66 90                	xchg   %ax,%ax
801033ce:	66 90                	xchg   %ax,%ax

801033d0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
801033d0:	55                   	push   %ebp
801033d1:	89 e5                	mov    %esp,%ebp
801033d3:	57                   	push   %edi
801033d4:	56                   	push   %esi
801033d5:	53                   	push   %ebx
801033d6:	83 ec 0c             	sub    $0xc,%esp
801033d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801033dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
801033df:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801033e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801033eb:	e8 60 da ff ff       	call   80100e50 <filealloc>
801033f0:	89 03                	mov    %eax,(%ebx)
801033f2:	85 c0                	test   %eax,%eax
801033f4:	0f 84 a8 00 00 00    	je     801034a2 <pipealloc+0xd2>
801033fa:	e8 51 da ff ff       	call   80100e50 <filealloc>
801033ff:	89 06                	mov    %eax,(%esi)
80103401:	85 c0                	test   %eax,%eax
80103403:	0f 84 87 00 00 00    	je     80103490 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103409:	e8 52 f2 ff ff       	call   80102660 <kalloc>
8010340e:	89 c7                	mov    %eax,%edi
80103410:	85 c0                	test   %eax,%eax
80103412:	0f 84 b0 00 00 00    	je     801034c8 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
80103418:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010341f:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103422:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
80103425:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010342c:	00 00 00 
  p->nwrite = 0;
8010342f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103436:	00 00 00 
  p->nread = 0;
80103439:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103440:	00 00 00 
  initlock(&p->lock, "pipe");
80103443:	68 b1 71 10 80       	push   $0x801071b1
80103448:	50                   	push   %eax
80103449:	e8 f2 0e 00 00       	call   80104340 <initlock>
  (*f0)->type = FD_PIPE;
8010344e:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
80103450:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103453:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103459:	8b 03                	mov    (%ebx),%eax
8010345b:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010345f:	8b 03                	mov    (%ebx),%eax
80103461:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103465:	8b 03                	mov    (%ebx),%eax
80103467:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010346a:	8b 06                	mov    (%esi),%eax
8010346c:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103472:	8b 06                	mov    (%esi),%eax
80103474:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103478:	8b 06                	mov    (%esi),%eax
8010347a:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010347e:	8b 06                	mov    (%esi),%eax
80103480:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
80103483:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80103486:	31 c0                	xor    %eax,%eax
}
80103488:	5b                   	pop    %ebx
80103489:	5e                   	pop    %esi
8010348a:	5f                   	pop    %edi
8010348b:	5d                   	pop    %ebp
8010348c:	c3                   	ret
8010348d:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
80103490:	8b 03                	mov    (%ebx),%eax
80103492:	85 c0                	test   %eax,%eax
80103494:	74 1e                	je     801034b4 <pipealloc+0xe4>
    fileclose(*f0);
80103496:	83 ec 0c             	sub    $0xc,%esp
80103499:	50                   	push   %eax
8010349a:	e8 71 da ff ff       	call   80100f10 <fileclose>
8010349f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801034a2:	8b 06                	mov    (%esi),%eax
801034a4:	85 c0                	test   %eax,%eax
801034a6:	74 0c                	je     801034b4 <pipealloc+0xe4>
    fileclose(*f1);
801034a8:	83 ec 0c             	sub    $0xc,%esp
801034ab:	50                   	push   %eax
801034ac:	e8 5f da ff ff       	call   80100f10 <fileclose>
801034b1:	83 c4 10             	add    $0x10,%esp
}
801034b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
801034b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801034bc:	5b                   	pop    %ebx
801034bd:	5e                   	pop    %esi
801034be:	5f                   	pop    %edi
801034bf:	5d                   	pop    %ebp
801034c0:	c3                   	ret
801034c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
801034c8:	8b 03                	mov    (%ebx),%eax
801034ca:	85 c0                	test   %eax,%eax
801034cc:	75 c8                	jne    80103496 <pipealloc+0xc6>
801034ce:	eb d2                	jmp    801034a2 <pipealloc+0xd2>

801034d0 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801034d0:	55                   	push   %ebp
801034d1:	89 e5                	mov    %esp,%ebp
801034d3:	56                   	push   %esi
801034d4:	53                   	push   %ebx
801034d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
801034d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
801034db:	83 ec 0c             	sub    $0xc,%esp
801034de:	53                   	push   %ebx
801034df:	e8 bc 0f 00 00       	call   801044a0 <acquire>
  if(writable){
801034e4:	83 c4 10             	add    $0x10,%esp
801034e7:	85 f6                	test   %esi,%esi
801034e9:	74 45                	je     80103530 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
801034eb:	83 ec 0c             	sub    $0xc,%esp
801034ee:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
801034f4:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
801034fb:	00 00 00 
    wakeup(&p->nread);
801034fe:	50                   	push   %eax
801034ff:	e8 6c 0b 00 00       	call   80104070 <wakeup>
80103504:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103507:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010350d:	85 d2                	test   %edx,%edx
8010350f:	75 0a                	jne    8010351b <pipeclose+0x4b>
80103511:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103517:	85 c0                	test   %eax,%eax
80103519:	74 35                	je     80103550 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010351b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010351e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103521:	5b                   	pop    %ebx
80103522:	5e                   	pop    %esi
80103523:	5d                   	pop    %ebp
    release(&p->lock);
80103524:	e9 37 10 00 00       	jmp    80104560 <release>
80103529:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    wakeup(&p->nwrite);
80103530:	83 ec 0c             	sub    $0xc,%esp
80103533:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
80103539:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103540:	00 00 00 
    wakeup(&p->nwrite);
80103543:	50                   	push   %eax
80103544:	e8 27 0b 00 00       	call   80104070 <wakeup>
80103549:	83 c4 10             	add    $0x10,%esp
8010354c:	eb b9                	jmp    80103507 <pipeclose+0x37>
8010354e:	66 90                	xchg   %ax,%ax
    release(&p->lock);
80103550:	83 ec 0c             	sub    $0xc,%esp
80103553:	53                   	push   %ebx
80103554:	e8 07 10 00 00       	call   80104560 <release>
    kfree((char*)p);
80103559:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010355c:	83 c4 10             	add    $0x10,%esp
}
8010355f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103562:	5b                   	pop    %ebx
80103563:	5e                   	pop    %esi
80103564:	5d                   	pop    %ebp
    kfree((char*)p);
80103565:	e9 36 ef ff ff       	jmp    801024a0 <kfree>
8010356a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103570 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103570:	55                   	push   %ebp
80103571:	89 e5                	mov    %esp,%ebp
80103573:	57                   	push   %edi
80103574:	56                   	push   %esi
80103575:	53                   	push   %ebx
80103576:	83 ec 28             	sub    $0x28,%esp
80103579:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010357c:	53                   	push   %ebx
8010357d:	e8 1e 0f 00 00       	call   801044a0 <acquire>
  for(i = 0; i < n; i++){
80103582:	8b 45 10             	mov    0x10(%ebp),%eax
80103585:	83 c4 10             	add    $0x10,%esp
80103588:	85 c0                	test   %eax,%eax
8010358a:	0f 8e c0 00 00 00    	jle    80103650 <pipewrite+0xe0>
80103590:	8b 45 0c             	mov    0xc(%ebp),%eax
80103593:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103599:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
8010359f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801035a2:	03 45 10             	add    0x10(%ebp),%eax
801035a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801035a8:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801035ae:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801035b4:	89 ca                	mov    %ecx,%edx
801035b6:	05 00 02 00 00       	add    $0x200,%eax
801035bb:	39 c1                	cmp    %eax,%ecx
801035bd:	74 3f                	je     801035fe <pipewrite+0x8e>
801035bf:	eb 67                	jmp    80103628 <pipewrite+0xb8>
801035c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->readopen == 0 || myproc()->killed){
801035c8:	e8 53 03 00 00       	call   80103920 <myproc>
801035cd:	8b 48 24             	mov    0x24(%eax),%ecx
801035d0:	85 c9                	test   %ecx,%ecx
801035d2:	75 34                	jne    80103608 <pipewrite+0x98>
      wakeup(&p->nread);
801035d4:	83 ec 0c             	sub    $0xc,%esp
801035d7:	57                   	push   %edi
801035d8:	e8 93 0a 00 00       	call   80104070 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801035dd:	58                   	pop    %eax
801035de:	5a                   	pop    %edx
801035df:	53                   	push   %ebx
801035e0:	56                   	push   %esi
801035e1:	e8 da 08 00 00       	call   80103ec0 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801035e6:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801035ec:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
801035f2:	83 c4 10             	add    $0x10,%esp
801035f5:	05 00 02 00 00       	add    $0x200,%eax
801035fa:	39 c2                	cmp    %eax,%edx
801035fc:	75 2a                	jne    80103628 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
801035fe:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103604:	85 c0                	test   %eax,%eax
80103606:	75 c0                	jne    801035c8 <pipewrite+0x58>
        release(&p->lock);
80103608:	83 ec 0c             	sub    $0xc,%esp
8010360b:	53                   	push   %ebx
8010360c:	e8 4f 0f 00 00       	call   80104560 <release>
        return -1;
80103611:	83 c4 10             	add    $0x10,%esp
80103614:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103619:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010361c:	5b                   	pop    %ebx
8010361d:	5e                   	pop    %esi
8010361e:	5f                   	pop    %edi
8010361f:	5d                   	pop    %ebp
80103620:	c3                   	ret
80103621:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103628:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010362b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010362e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103634:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
8010363a:	0f b6 06             	movzbl (%esi),%eax
8010363d:	83 c6 01             	add    $0x1,%esi
80103640:	89 75 e4             	mov    %esi,-0x1c(%ebp)
80103643:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103647:	3b 75 e0             	cmp    -0x20(%ebp),%esi
8010364a:	0f 85 58 ff ff ff    	jne    801035a8 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103650:	83 ec 0c             	sub    $0xc,%esp
80103653:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103659:	50                   	push   %eax
8010365a:	e8 11 0a 00 00       	call   80104070 <wakeup>
  release(&p->lock);
8010365f:	89 1c 24             	mov    %ebx,(%esp)
80103662:	e8 f9 0e 00 00       	call   80104560 <release>
  return n;
80103667:	8b 45 10             	mov    0x10(%ebp),%eax
8010366a:	83 c4 10             	add    $0x10,%esp
8010366d:	eb aa                	jmp    80103619 <pipewrite+0xa9>
8010366f:	90                   	nop

80103670 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103670:	55                   	push   %ebp
80103671:	89 e5                	mov    %esp,%ebp
80103673:	57                   	push   %edi
80103674:	56                   	push   %esi
80103675:	53                   	push   %ebx
80103676:	83 ec 18             	sub    $0x18,%esp
80103679:	8b 75 08             	mov    0x8(%ebp),%esi
8010367c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
8010367f:	56                   	push   %esi
80103680:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
80103686:	e8 15 0e 00 00       	call   801044a0 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010368b:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103691:	83 c4 10             	add    $0x10,%esp
80103694:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
8010369a:	74 2f                	je     801036cb <piperead+0x5b>
8010369c:	eb 37                	jmp    801036d5 <piperead+0x65>
8010369e:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
801036a0:	e8 7b 02 00 00       	call   80103920 <myproc>
801036a5:	8b 48 24             	mov    0x24(%eax),%ecx
801036a8:	85 c9                	test   %ecx,%ecx
801036aa:	0f 85 80 00 00 00    	jne    80103730 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801036b0:	83 ec 08             	sub    $0x8,%esp
801036b3:	56                   	push   %esi
801036b4:	53                   	push   %ebx
801036b5:	e8 06 08 00 00       	call   80103ec0 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801036ba:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
801036c0:	83 c4 10             	add    $0x10,%esp
801036c3:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
801036c9:	75 0a                	jne    801036d5 <piperead+0x65>
801036cb:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
801036d1:	85 c0                	test   %eax,%eax
801036d3:	75 cb                	jne    801036a0 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801036d5:	8b 55 10             	mov    0x10(%ebp),%edx
801036d8:	31 db                	xor    %ebx,%ebx
801036da:	85 d2                	test   %edx,%edx
801036dc:	7f 20                	jg     801036fe <piperead+0x8e>
801036de:	eb 2c                	jmp    8010370c <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801036e0:	8d 48 01             	lea    0x1(%eax),%ecx
801036e3:	25 ff 01 00 00       	and    $0x1ff,%eax
801036e8:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
801036ee:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
801036f3:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801036f6:	83 c3 01             	add    $0x1,%ebx
801036f9:	39 5d 10             	cmp    %ebx,0x10(%ebp)
801036fc:	74 0e                	je     8010370c <piperead+0x9c>
    if(p->nread == p->nwrite)
801036fe:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103704:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
8010370a:	75 d4                	jne    801036e0 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010370c:	83 ec 0c             	sub    $0xc,%esp
8010370f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103715:	50                   	push   %eax
80103716:	e8 55 09 00 00       	call   80104070 <wakeup>
  release(&p->lock);
8010371b:	89 34 24             	mov    %esi,(%esp)
8010371e:	e8 3d 0e 00 00       	call   80104560 <release>
  return i;
80103723:	83 c4 10             	add    $0x10,%esp
}
80103726:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103729:	89 d8                	mov    %ebx,%eax
8010372b:	5b                   	pop    %ebx
8010372c:	5e                   	pop    %esi
8010372d:	5f                   	pop    %edi
8010372e:	5d                   	pop    %ebp
8010372f:	c3                   	ret
      release(&p->lock);
80103730:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103733:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103738:	56                   	push   %esi
80103739:	e8 22 0e 00 00       	call   80104560 <release>
      return -1;
8010373e:	83 c4 10             	add    $0x10,%esp
}
80103741:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103744:	89 d8                	mov    %ebx,%eax
80103746:	5b                   	pop    %ebx
80103747:	5e                   	pop    %esi
80103748:	5f                   	pop    %edi
80103749:	5d                   	pop    %ebp
8010374a:	c3                   	ret
8010374b:	66 90                	xchg   %ax,%ax
8010374d:	66 90                	xchg   %ax,%ax
8010374f:	90                   	nop

80103750 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103750:	55                   	push   %ebp
80103751:	89 e5                	mov    %esp,%ebp
80103753:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103754:	bb 34 ae 15 88       	mov    $0x8815ae34,%ebx
{
80103759:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010375c:	68 00 ae 15 88       	push   $0x8815ae00
80103761:	e8 3a 0d 00 00       	call   801044a0 <acquire>
80103766:	83 c4 10             	add    $0x10,%esp
80103769:	eb 10                	jmp    8010377b <allocproc+0x2b>
8010376b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103770:	83 c3 7c             	add    $0x7c,%ebx
80103773:	81 fb 34 cd 15 88    	cmp    $0x8815cd34,%ebx
80103779:	74 75                	je     801037f0 <allocproc+0xa0>
    if(p->state == UNUSED)
8010377b:	8b 43 0c             	mov    0xc(%ebx),%eax
8010377e:	85 c0                	test   %eax,%eax
80103780:	75 ee                	jne    80103770 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103782:	a1 04 a0 10 80       	mov    0x8010a004,%eax

  release(&ptable.lock);
80103787:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
8010378a:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103791:	89 43 10             	mov    %eax,0x10(%ebx)
80103794:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
80103797:	68 00 ae 15 88       	push   $0x8815ae00
  p->pid = nextpid++;
8010379c:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
  release(&ptable.lock);
801037a2:	e8 b9 0d 00 00       	call   80104560 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801037a7:	e8 b4 ee ff ff       	call   80102660 <kalloc>
801037ac:	83 c4 10             	add    $0x10,%esp
801037af:	89 43 08             	mov    %eax,0x8(%ebx)
801037b2:	85 c0                	test   %eax,%eax
801037b4:	74 53                	je     80103809 <allocproc+0xb9>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801037b6:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
801037bc:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
801037bf:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
801037c4:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801037c7:	c7 40 14 42 57 10 80 	movl   $0x80105742,0x14(%eax)
  p->context = (struct context*)sp;
801037ce:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801037d1:	6a 14                	push   $0x14
801037d3:	6a 00                	push   $0x0
801037d5:	50                   	push   %eax
801037d6:	e8 d5 0d 00 00       	call   801045b0 <memset>
  p->context->eip = (uint)forkret;
801037db:	8b 43 1c             	mov    0x1c(%ebx),%eax

  return p;
801037de:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801037e1:	c7 40 10 20 38 10 80 	movl   $0x80103820,0x10(%eax)
}
801037e8:	89 d8                	mov    %ebx,%eax
801037ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801037ed:	c9                   	leave
801037ee:	c3                   	ret
801037ef:	90                   	nop
  release(&ptable.lock);
801037f0:	83 ec 0c             	sub    $0xc,%esp
  return 0;
801037f3:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
801037f5:	68 00 ae 15 88       	push   $0x8815ae00
801037fa:	e8 61 0d 00 00       	call   80104560 <release>
}
801037ff:	89 d8                	mov    %ebx,%eax
  return 0;
80103801:	83 c4 10             	add    $0x10,%esp
}
80103804:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103807:	c9                   	leave
80103808:	c3                   	ret
    p->state = UNUSED;
80103809:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103810:	31 db                	xor    %ebx,%ebx
}
80103812:	89 d8                	mov    %ebx,%eax
80103814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103817:	c9                   	leave
80103818:	c3                   	ret
80103819:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103820 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103820:	55                   	push   %ebp
80103821:	89 e5                	mov    %esp,%ebp
80103823:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103826:	68 00 ae 15 88       	push   $0x8815ae00
8010382b:	e8 30 0d 00 00       	call   80104560 <release>

  if (first) {
80103830:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80103835:	83 c4 10             	add    $0x10,%esp
80103838:	85 c0                	test   %eax,%eax
8010383a:	75 04                	jne    80103840 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010383c:	c9                   	leave
8010383d:	c3                   	ret
8010383e:	66 90                	xchg   %ax,%ax
    first = 0;
80103840:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103847:	00 00 00 
    iinit(ROOTDEV);
8010384a:	83 ec 0c             	sub    $0xc,%esp
8010384d:	6a 01                	push   $0x1
8010384f:	e8 2c dd ff ff       	call   80101580 <iinit>
    initlog(ROOTDEV);
80103854:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010385b:	e8 40 f4 ff ff       	call   80102ca0 <initlog>
}
80103860:	83 c4 10             	add    $0x10,%esp
80103863:	c9                   	leave
80103864:	c3                   	ret
80103865:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010386c:	00 
8010386d:	8d 76 00             	lea    0x0(%esi),%esi

80103870 <pinit>:
{
80103870:	55                   	push   %ebp
80103871:	89 e5                	mov    %esp,%ebp
80103873:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103876:	68 b6 71 10 80       	push   $0x801071b6
8010387b:	68 00 ae 15 88       	push   $0x8815ae00
80103880:	e8 bb 0a 00 00       	call   80104340 <initlock>
}
80103885:	83 c4 10             	add    $0x10,%esp
80103888:	c9                   	leave
80103889:	c3                   	ret
8010388a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103890 <mycpu>:
{
80103890:	55                   	push   %ebp
80103891:	89 e5                	mov    %esp,%ebp
80103893:	56                   	push   %esi
80103894:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103895:	9c                   	pushf
80103896:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103897:	f6 c4 02             	test   $0x2,%ah
8010389a:	75 4e                	jne    801038ea <mycpu+0x5a>
  apicid = lapicid();
8010389c:	e8 2f f0 ff ff       	call   801028d0 <lapicid>
  for (i = 0; i < ncpu; ++i) {
801038a1:	8b 35 e0 ad 15 88    	mov    0x8815ade0,%esi
  apicid = lapicid();
801038a7:	89 c3                	mov    %eax,%ebx
  for (i = 0; i < ncpu; ++i) {
801038a9:	85 f6                	test   %esi,%esi
801038ab:	7e 30                	jle    801038dd <mycpu+0x4d>
801038ad:	31 d2                	xor    %edx,%edx
801038af:	eb 0e                	jmp    801038bf <mycpu+0x2f>
801038b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801038b8:	83 c2 01             	add    $0x1,%edx
801038bb:	39 f2                	cmp    %esi,%edx
801038bd:	74 1e                	je     801038dd <mycpu+0x4d>
    if (cpus[i].apicid == apicid)
801038bf:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801038c5:	0f b6 81 60 a8 15 88 	movzbl -0x77ea57a0(%ecx),%eax
801038cc:	39 d8                	cmp    %ebx,%eax
801038ce:	75 e8                	jne    801038b8 <mycpu+0x28>
}
801038d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
801038d3:	8d 81 60 a8 15 88    	lea    -0x77ea57a0(%ecx),%eax
}
801038d9:	5b                   	pop    %ebx
801038da:	5e                   	pop    %esi
801038db:	5d                   	pop    %ebp
801038dc:	c3                   	ret
  panic("unknown apicid\n");
801038dd:	83 ec 0c             	sub    $0xc,%esp
801038e0:	68 bd 71 10 80       	push   $0x801071bd
801038e5:	e8 96 ca ff ff       	call   80100380 <panic>
    panic("mycpu called with interrupts enabled\n");
801038ea:	83 ec 0c             	sub    $0xc,%esp
801038ed:	68 1c 75 10 80       	push   $0x8010751c
801038f2:	e8 89 ca ff ff       	call   80100380 <panic>
801038f7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801038fe:	00 
801038ff:	90                   	nop

80103900 <cpuid>:
cpuid() {
80103900:	55                   	push   %ebp
80103901:	89 e5                	mov    %esp,%ebp
80103903:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103906:	e8 85 ff ff ff       	call   80103890 <mycpu>
}
8010390b:	c9                   	leave
  return mycpu()-cpus;
8010390c:	2d 60 a8 15 88       	sub    $0x8815a860,%eax
80103911:	c1 f8 04             	sar    $0x4,%eax
80103914:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010391a:	c3                   	ret
8010391b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80103920 <myproc>:
myproc(void) {
80103920:	55                   	push   %ebp
80103921:	89 e5                	mov    %esp,%ebp
80103923:	53                   	push   %ebx
80103924:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103927:	e8 84 0a 00 00       	call   801043b0 <pushcli>
  c = mycpu();
8010392c:	e8 5f ff ff ff       	call   80103890 <mycpu>
  p = c->proc;
80103931:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103937:	e8 c4 0a 00 00       	call   80104400 <popcli>
}
8010393c:	83 c4 04             	add    $0x4,%esp
8010393f:	89 d8                	mov    %ebx,%eax
80103941:	5b                   	pop    %ebx
80103942:	5d                   	pop    %ebp
80103943:	c3                   	ret
80103944:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010394b:	00 
8010394c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103950 <userinit>:
{
80103950:	55                   	push   %ebp
80103951:	89 e5                	mov    %esp,%ebp
80103953:	53                   	push   %ebx
80103954:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103957:	e8 f4 fd ff ff       	call   80103750 <allocproc>
8010395c:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010395e:	a3 24 98 15 88       	mov    %eax,0x88159824
  if((p->pgdir = setupkvm()) == 0)
80103963:	e8 68 33 00 00       	call   80106cd0 <setupkvm>
80103968:	89 43 04             	mov    %eax,0x4(%ebx)
8010396b:	85 c0                	test   %eax,%eax
8010396d:	0f 84 bd 00 00 00    	je     80103a30 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103973:	83 ec 04             	sub    $0x4,%esp
80103976:	68 dc 80 04 08       	push   $0x80480dc
8010397b:	68 60 a4 10 80       	push   $0x8010a460
80103980:	50                   	push   %eax
80103981:	e8 2a 30 00 00       	call   801069b0 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103986:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103989:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010398f:	6a 4c                	push   $0x4c
80103991:	6a 00                	push   $0x0
80103993:	ff 73 18             	push   0x18(%ebx)
80103996:	e8 15 0c 00 00       	call   801045b0 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010399b:	8b 43 18             	mov    0x18(%ebx),%eax
8010399e:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
801039a3:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801039a6:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801039ab:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801039af:	8b 43 18             	mov    0x18(%ebx),%eax
801039b2:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
801039b6:	8b 43 18             	mov    0x18(%ebx),%eax
801039b9:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801039bd:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801039c1:	8b 43 18             	mov    0x18(%ebx),%eax
801039c4:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801039c8:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801039cc:	8b 43 18             	mov    0x18(%ebx),%eax
801039cf:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801039d6:	8b 43 18             	mov    0x18(%ebx),%eax
801039d9:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801039e0:	8b 43 18             	mov    0x18(%ebx),%eax
801039e3:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801039ea:	8d 43 6c             	lea    0x6c(%ebx),%eax
801039ed:	6a 10                	push   $0x10
801039ef:	68 e6 71 10 80       	push   $0x801071e6
801039f4:	50                   	push   %eax
801039f5:	e8 76 0d 00 00       	call   80104770 <safestrcpy>
  p->cwd = namei("/");
801039fa:	c7 04 24 ef 71 10 80 	movl   $0x801071ef,(%esp)
80103a01:	e8 7a e6 ff ff       	call   80102080 <namei>
80103a06:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103a09:	c7 04 24 00 ae 15 88 	movl   $0x8815ae00,(%esp)
80103a10:	e8 8b 0a 00 00       	call   801044a0 <acquire>
  p->state = RUNNABLE;
80103a15:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103a1c:	c7 04 24 00 ae 15 88 	movl   $0x8815ae00,(%esp)
80103a23:	e8 38 0b 00 00       	call   80104560 <release>
}
80103a28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a2b:	83 c4 10             	add    $0x10,%esp
80103a2e:	c9                   	leave
80103a2f:	c3                   	ret
    panic("userinit: out of memory?");
80103a30:	83 ec 0c             	sub    $0xc,%esp
80103a33:	68 cd 71 10 80       	push   $0x801071cd
80103a38:	e8 43 c9 ff ff       	call   80100380 <panic>
80103a3d:	8d 76 00             	lea    0x0(%esi),%esi

80103a40 <growproc>:
{
80103a40:	55                   	push   %ebp
80103a41:	89 e5                	mov    %esp,%ebp
80103a43:	56                   	push   %esi
80103a44:	53                   	push   %ebx
80103a45:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103a48:	e8 63 09 00 00       	call   801043b0 <pushcli>
  c = mycpu();
80103a4d:	e8 3e fe ff ff       	call   80103890 <mycpu>
  p = c->proc;
80103a52:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103a58:	e8 a3 09 00 00       	call   80104400 <popcli>
  sz = curproc->sz;
80103a5d:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103a5f:	85 f6                	test   %esi,%esi
80103a61:	7f 1d                	jg     80103a80 <growproc+0x40>
  } else if(n < 0){
80103a63:	75 3b                	jne    80103aa0 <growproc+0x60>
  switchuvm(curproc);
80103a65:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103a68:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103a6a:	53                   	push   %ebx
80103a6b:	e8 30 2e 00 00       	call   801068a0 <switchuvm>
  return 0;
80103a70:	83 c4 10             	add    $0x10,%esp
80103a73:	31 c0                	xor    %eax,%eax
}
80103a75:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a78:	5b                   	pop    %ebx
80103a79:	5e                   	pop    %esi
80103a7a:	5d                   	pop    %ebp
80103a7b:	c3                   	ret
80103a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103a80:	83 ec 04             	sub    $0x4,%esp
80103a83:	01 c6                	add    %eax,%esi
80103a85:	56                   	push   %esi
80103a86:	50                   	push   %eax
80103a87:	ff 73 04             	push   0x4(%ebx)
80103a8a:	e8 61 30 00 00       	call   80106af0 <allocuvm>
80103a8f:	83 c4 10             	add    $0x10,%esp
80103a92:	85 c0                	test   %eax,%eax
80103a94:	75 cf                	jne    80103a65 <growproc+0x25>
      return -1;
80103a96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a9b:	eb d8                	jmp    80103a75 <growproc+0x35>
80103a9d:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103aa0:	83 ec 04             	sub    $0x4,%esp
80103aa3:	01 c6                	add    %eax,%esi
80103aa5:	56                   	push   %esi
80103aa6:	50                   	push   %eax
80103aa7:	ff 73 04             	push   0x4(%ebx)
80103aaa:	e8 71 31 00 00       	call   80106c20 <deallocuvm>
80103aaf:	83 c4 10             	add    $0x10,%esp
80103ab2:	85 c0                	test   %eax,%eax
80103ab4:	75 af                	jne    80103a65 <growproc+0x25>
80103ab6:	eb de                	jmp    80103a96 <growproc+0x56>
80103ab8:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80103abf:	00 

80103ac0 <fork>:
{
80103ac0:	55                   	push   %ebp
80103ac1:	89 e5                	mov    %esp,%ebp
80103ac3:	57                   	push   %edi
80103ac4:	56                   	push   %esi
80103ac5:	53                   	push   %ebx
80103ac6:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103ac9:	e8 e2 08 00 00       	call   801043b0 <pushcli>
  c = mycpu();
80103ace:	e8 bd fd ff ff       	call   80103890 <mycpu>
  p = c->proc;
80103ad3:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103ad9:	e8 22 09 00 00       	call   80104400 <popcli>
  if((np = allocproc()) == 0){
80103ade:	e8 6d fc ff ff       	call   80103750 <allocproc>
80103ae3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103ae6:	85 c0                	test   %eax,%eax
80103ae8:	0f 84 b7 00 00 00    	je     80103ba5 <fork+0xe5>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103aee:	83 ec 08             	sub    $0x8,%esp
80103af1:	ff 33                	push   (%ebx)
80103af3:	89 c7                	mov    %eax,%edi
80103af5:	ff 73 04             	push   0x4(%ebx)
80103af8:	e8 a3 32 00 00       	call   80106da0 <copyuvm>
80103afd:	83 c4 10             	add    $0x10,%esp
80103b00:	89 47 04             	mov    %eax,0x4(%edi)
80103b03:	85 c0                	test   %eax,%eax
80103b05:	0f 84 a1 00 00 00    	je     80103bac <fork+0xec>
  np->sz = curproc->sz;
80103b0b:	8b 03                	mov    (%ebx),%eax
80103b0d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103b10:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
80103b12:	8b 79 18             	mov    0x18(%ecx),%edi
  np->parent = curproc;
80103b15:	89 c8                	mov    %ecx,%eax
80103b17:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103b1a:	b9 13 00 00 00       	mov    $0x13,%ecx
80103b1f:	8b 73 18             	mov    0x18(%ebx),%esi
80103b22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103b24:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103b26:	8b 40 18             	mov    0x18(%eax),%eax
80103b29:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    if(curproc->ofile[i])
80103b30:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103b34:	85 c0                	test   %eax,%eax
80103b36:	74 13                	je     80103b4b <fork+0x8b>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103b38:	83 ec 0c             	sub    $0xc,%esp
80103b3b:	50                   	push   %eax
80103b3c:	e8 7f d3 ff ff       	call   80100ec0 <filedup>
80103b41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103b44:	83 c4 10             	add    $0x10,%esp
80103b47:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103b4b:	83 c6 01             	add    $0x1,%esi
80103b4e:	83 fe 10             	cmp    $0x10,%esi
80103b51:	75 dd                	jne    80103b30 <fork+0x70>
  np->cwd = idup(curproc->cwd);
80103b53:	83 ec 0c             	sub    $0xc,%esp
80103b56:	ff 73 68             	push   0x68(%ebx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103b59:	83 c3 6c             	add    $0x6c,%ebx
  np->cwd = idup(curproc->cwd);
80103b5c:	e8 0f dc ff ff       	call   80101770 <idup>
80103b61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103b64:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103b67:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103b6a:	8d 47 6c             	lea    0x6c(%edi),%eax
80103b6d:	6a 10                	push   $0x10
80103b6f:	53                   	push   %ebx
80103b70:	50                   	push   %eax
80103b71:	e8 fa 0b 00 00       	call   80104770 <safestrcpy>
  pid = np->pid;
80103b76:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103b79:	c7 04 24 00 ae 15 88 	movl   $0x8815ae00,(%esp)
80103b80:	e8 1b 09 00 00       	call   801044a0 <acquire>
  np->state = RUNNABLE;
80103b85:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103b8c:	c7 04 24 00 ae 15 88 	movl   $0x8815ae00,(%esp)
80103b93:	e8 c8 09 00 00       	call   80104560 <release>
  return pid;
80103b98:	83 c4 10             	add    $0x10,%esp
}
80103b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103b9e:	89 d8                	mov    %ebx,%eax
80103ba0:	5b                   	pop    %ebx
80103ba1:	5e                   	pop    %esi
80103ba2:	5f                   	pop    %edi
80103ba3:	5d                   	pop    %ebp
80103ba4:	c3                   	ret
    return -1;
80103ba5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103baa:	eb ef                	jmp    80103b9b <fork+0xdb>
    kfree(np->kstack);
80103bac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103baf:	83 ec 0c             	sub    $0xc,%esp
80103bb2:	ff 73 08             	push   0x8(%ebx)
80103bb5:	e8 e6 e8 ff ff       	call   801024a0 <kfree>
    np->kstack = 0;
80103bba:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    return -1;
80103bc1:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80103bc4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103bcb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103bd0:	eb c9                	jmp    80103b9b <fork+0xdb>
80103bd2:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80103bd9:	00 
80103bda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103be0 <scheduler>:
{
80103be0:	55                   	push   %ebp
80103be1:	89 e5                	mov    %esp,%ebp
80103be3:	57                   	push   %edi
80103be4:	56                   	push   %esi
80103be5:	53                   	push   %ebx
80103be6:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103be9:	e8 a2 fc ff ff       	call   80103890 <mycpu>
  c->proc = 0;
80103bee:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103bf5:	00 00 00 
  struct cpu *c = mycpu();
80103bf8:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103bfa:	8d 78 04             	lea    0x4(%eax),%edi
80103bfd:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103c00:	fb                   	sti
    acquire(&ptable.lock);
80103c01:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c04:	bb 34 ae 15 88       	mov    $0x8815ae34,%ebx
    acquire(&ptable.lock);
80103c09:	68 00 ae 15 88       	push   $0x8815ae00
80103c0e:	e8 8d 08 00 00       	call   801044a0 <acquire>
80103c13:	83 c4 10             	add    $0x10,%esp
80103c16:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80103c1d:	00 
80103c1e:	66 90                	xchg   %ax,%ax
      if(p->state != RUNNABLE)
80103c20:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103c24:	75 33                	jne    80103c59 <scheduler+0x79>
      switchuvm(p);
80103c26:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103c29:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103c2f:	53                   	push   %ebx
80103c30:	e8 6b 2c 00 00       	call   801068a0 <switchuvm>
      swtch(&(c->scheduler), p->context);
80103c35:	58                   	pop    %eax
80103c36:	5a                   	pop    %edx
80103c37:	ff 73 1c             	push   0x1c(%ebx)
80103c3a:	57                   	push   %edi
      p->state = RUNNING;
80103c3b:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103c42:	e8 84 0b 00 00       	call   801047cb <swtch>
      switchkvm();
80103c47:	e8 44 2c 00 00       	call   80106890 <switchkvm>
      c->proc = 0;
80103c4c:	83 c4 10             	add    $0x10,%esp
80103c4f:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103c56:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c59:	83 c3 7c             	add    $0x7c,%ebx
80103c5c:	81 fb 34 cd 15 88    	cmp    $0x8815cd34,%ebx
80103c62:	75 bc                	jne    80103c20 <scheduler+0x40>
    release(&ptable.lock);
80103c64:	83 ec 0c             	sub    $0xc,%esp
80103c67:	68 00 ae 15 88       	push   $0x8815ae00
80103c6c:	e8 ef 08 00 00       	call   80104560 <release>
    sti();
80103c71:	83 c4 10             	add    $0x10,%esp
80103c74:	eb 8a                	jmp    80103c00 <scheduler+0x20>
80103c76:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80103c7d:	00 
80103c7e:	66 90                	xchg   %ax,%ax

80103c80 <sched>:
{
80103c80:	55                   	push   %ebp
80103c81:	89 e5                	mov    %esp,%ebp
80103c83:	56                   	push   %esi
80103c84:	53                   	push   %ebx
  pushcli();
80103c85:	e8 26 07 00 00       	call   801043b0 <pushcli>
  c = mycpu();
80103c8a:	e8 01 fc ff ff       	call   80103890 <mycpu>
  p = c->proc;
80103c8f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103c95:	e8 66 07 00 00       	call   80104400 <popcli>
  if(!holding(&ptable.lock))
80103c9a:	83 ec 0c             	sub    $0xc,%esp
80103c9d:	68 00 ae 15 88       	push   $0x8815ae00
80103ca2:	e8 b9 07 00 00       	call   80104460 <holding>
80103ca7:	83 c4 10             	add    $0x10,%esp
80103caa:	85 c0                	test   %eax,%eax
80103cac:	74 4f                	je     80103cfd <sched+0x7d>
  if(mycpu()->ncli != 1)
80103cae:	e8 dd fb ff ff       	call   80103890 <mycpu>
80103cb3:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103cba:	75 68                	jne    80103d24 <sched+0xa4>
  if(p->state == RUNNING)
80103cbc:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103cc0:	74 55                	je     80103d17 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103cc2:	9c                   	pushf
80103cc3:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103cc4:	f6 c4 02             	test   $0x2,%ah
80103cc7:	75 41                	jne    80103d0a <sched+0x8a>
  intena = mycpu()->intena;
80103cc9:	e8 c2 fb ff ff       	call   80103890 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
80103cce:	83 c3 1c             	add    $0x1c,%ebx
  intena = mycpu()->intena;
80103cd1:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103cd7:	e8 b4 fb ff ff       	call   80103890 <mycpu>
80103cdc:	83 ec 08             	sub    $0x8,%esp
80103cdf:	ff 70 04             	push   0x4(%eax)
80103ce2:	53                   	push   %ebx
80103ce3:	e8 e3 0a 00 00       	call   801047cb <swtch>
  mycpu()->intena = intena;
80103ce8:	e8 a3 fb ff ff       	call   80103890 <mycpu>
}
80103ced:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80103cf0:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103cf6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103cf9:	5b                   	pop    %ebx
80103cfa:	5e                   	pop    %esi
80103cfb:	5d                   	pop    %ebp
80103cfc:	c3                   	ret
    panic("sched ptable.lock");
80103cfd:	83 ec 0c             	sub    $0xc,%esp
80103d00:	68 f1 71 10 80       	push   $0x801071f1
80103d05:	e8 76 c6 ff ff       	call   80100380 <panic>
    panic("sched interruptible");
80103d0a:	83 ec 0c             	sub    $0xc,%esp
80103d0d:	68 1d 72 10 80       	push   $0x8010721d
80103d12:	e8 69 c6 ff ff       	call   80100380 <panic>
    panic("sched running");
80103d17:	83 ec 0c             	sub    $0xc,%esp
80103d1a:	68 0f 72 10 80       	push   $0x8010720f
80103d1f:	e8 5c c6 ff ff       	call   80100380 <panic>
    panic("sched locks");
80103d24:	83 ec 0c             	sub    $0xc,%esp
80103d27:	68 03 72 10 80       	push   $0x80107203
80103d2c:	e8 4f c6 ff ff       	call   80100380 <panic>
80103d31:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80103d38:	00 
80103d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103d40 <exit>:
{
80103d40:	55                   	push   %ebp
80103d41:	89 e5                	mov    %esp,%ebp
80103d43:	57                   	push   %edi
80103d44:	56                   	push   %esi
80103d45:	53                   	push   %ebx
80103d46:	83 ec 0c             	sub    $0xc,%esp
  pushcli();
80103d49:	e8 62 06 00 00       	call   801043b0 <pushcli>
  c = mycpu();
80103d4e:	e8 3d fb ff ff       	call   80103890 <mycpu>
  p = c->proc;
80103d53:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80103d59:	e8 a2 06 00 00       	call   80104400 <popcli>
  if(curproc == initproc)
80103d5e:	8d 5e 28             	lea    0x28(%esi),%ebx
80103d61:	8d 7e 68             	lea    0x68(%esi),%edi
80103d64:	39 35 24 98 15 88    	cmp    %esi,0x88159824
80103d6a:	0f 84 e7 00 00 00    	je     80103e57 <exit+0x117>
    if(curproc->ofile[fd]){
80103d70:	8b 03                	mov    (%ebx),%eax
80103d72:	85 c0                	test   %eax,%eax
80103d74:	74 12                	je     80103d88 <exit+0x48>
      fileclose(curproc->ofile[fd]);
80103d76:	83 ec 0c             	sub    $0xc,%esp
80103d79:	50                   	push   %eax
80103d7a:	e8 91 d1 ff ff       	call   80100f10 <fileclose>
      curproc->ofile[fd] = 0;
80103d7f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80103d85:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103d88:	83 c3 04             	add    $0x4,%ebx
80103d8b:	39 df                	cmp    %ebx,%edi
80103d8d:	75 e1                	jne    80103d70 <exit+0x30>
  begin_op();
80103d8f:	e8 ac ef ff ff       	call   80102d40 <begin_op>
  iput(curproc->cwd);
80103d94:	83 ec 0c             	sub    $0xc,%esp
80103d97:	ff 76 68             	push   0x68(%esi)
80103d9a:	e8 31 db ff ff       	call   801018d0 <iput>
  end_op();
80103d9f:	e8 0c f0 ff ff       	call   80102db0 <end_op>
  curproc->cwd = 0;
80103da4:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103dab:	c7 04 24 00 ae 15 88 	movl   $0x8815ae00,(%esp)
80103db2:	e8 e9 06 00 00       	call   801044a0 <acquire>
  wakeup1(curproc->parent);
80103db7:	8b 56 14             	mov    0x14(%esi),%edx
80103dba:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103dbd:	b8 34 ae 15 88       	mov    $0x8815ae34,%eax
80103dc2:	eb 0e                	jmp    80103dd2 <exit+0x92>
80103dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103dc8:	83 c0 7c             	add    $0x7c,%eax
80103dcb:	3d 34 cd 15 88       	cmp    $0x8815cd34,%eax
80103dd0:	74 1c                	je     80103dee <exit+0xae>
    if(p->state == SLEEPING && p->chan == chan)
80103dd2:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103dd6:	75 f0                	jne    80103dc8 <exit+0x88>
80103dd8:	3b 50 20             	cmp    0x20(%eax),%edx
80103ddb:	75 eb                	jne    80103dc8 <exit+0x88>
      p->state = RUNNABLE;
80103ddd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103de4:	83 c0 7c             	add    $0x7c,%eax
80103de7:	3d 34 cd 15 88       	cmp    $0x8815cd34,%eax
80103dec:	75 e4                	jne    80103dd2 <exit+0x92>
      p->parent = initproc;
80103dee:	8b 0d 24 98 15 88    	mov    0x88159824,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103df4:	ba 34 ae 15 88       	mov    $0x8815ae34,%edx
80103df9:	eb 10                	jmp    80103e0b <exit+0xcb>
80103dfb:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
80103e00:	83 c2 7c             	add    $0x7c,%edx
80103e03:	81 fa 34 cd 15 88    	cmp    $0x8815cd34,%edx
80103e09:	74 33                	je     80103e3e <exit+0xfe>
    if(p->parent == curproc){
80103e0b:	39 72 14             	cmp    %esi,0x14(%edx)
80103e0e:	75 f0                	jne    80103e00 <exit+0xc0>
      if(p->state == ZOMBIE)
80103e10:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
      p->parent = initproc;
80103e14:	89 4a 14             	mov    %ecx,0x14(%edx)
      if(p->state == ZOMBIE)
80103e17:	75 e7                	jne    80103e00 <exit+0xc0>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103e19:	b8 34 ae 15 88       	mov    $0x8815ae34,%eax
80103e1e:	eb 0a                	jmp    80103e2a <exit+0xea>
80103e20:	83 c0 7c             	add    $0x7c,%eax
80103e23:	3d 34 cd 15 88       	cmp    $0x8815cd34,%eax
80103e28:	74 d6                	je     80103e00 <exit+0xc0>
    if(p->state == SLEEPING && p->chan == chan)
80103e2a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103e2e:	75 f0                	jne    80103e20 <exit+0xe0>
80103e30:	3b 48 20             	cmp    0x20(%eax),%ecx
80103e33:	75 eb                	jne    80103e20 <exit+0xe0>
      p->state = RUNNABLE;
80103e35:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103e3c:	eb e2                	jmp    80103e20 <exit+0xe0>
  curproc->state = ZOMBIE;
80103e3e:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103e45:	e8 36 fe ff ff       	call   80103c80 <sched>
  panic("zombie exit");
80103e4a:	83 ec 0c             	sub    $0xc,%esp
80103e4d:	68 3e 72 10 80       	push   $0x8010723e
80103e52:	e8 29 c5 ff ff       	call   80100380 <panic>
    panic("init exiting");
80103e57:	83 ec 0c             	sub    $0xc,%esp
80103e5a:	68 31 72 10 80       	push   $0x80107231
80103e5f:	e8 1c c5 ff ff       	call   80100380 <panic>
80103e64:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80103e6b:	00 
80103e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103e70 <yield>:
{
80103e70:	55                   	push   %ebp
80103e71:	89 e5                	mov    %esp,%ebp
80103e73:	53                   	push   %ebx
80103e74:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103e77:	68 00 ae 15 88       	push   $0x8815ae00
80103e7c:	e8 1f 06 00 00       	call   801044a0 <acquire>
  pushcli();
80103e81:	e8 2a 05 00 00       	call   801043b0 <pushcli>
  c = mycpu();
80103e86:	e8 05 fa ff ff       	call   80103890 <mycpu>
  p = c->proc;
80103e8b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103e91:	e8 6a 05 00 00       	call   80104400 <popcli>
  myproc()->state = RUNNABLE;
80103e96:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched();
80103e9d:	e8 de fd ff ff       	call   80103c80 <sched>
  release(&ptable.lock);
80103ea2:	c7 04 24 00 ae 15 88 	movl   $0x8815ae00,(%esp)
80103ea9:	e8 b2 06 00 00       	call   80104560 <release>
}
80103eae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103eb1:	83 c4 10             	add    $0x10,%esp
80103eb4:	c9                   	leave
80103eb5:	c3                   	ret
80103eb6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80103ebd:	00 
80103ebe:	66 90                	xchg   %ax,%ax

80103ec0 <sleep>:
{
80103ec0:	55                   	push   %ebp
80103ec1:	89 e5                	mov    %esp,%ebp
80103ec3:	57                   	push   %edi
80103ec4:	56                   	push   %esi
80103ec5:	53                   	push   %ebx
80103ec6:	83 ec 0c             	sub    $0xc,%esp
80103ec9:	8b 7d 08             	mov    0x8(%ebp),%edi
80103ecc:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
80103ecf:	e8 dc 04 00 00       	call   801043b0 <pushcli>
  c = mycpu();
80103ed4:	e8 b7 f9 ff ff       	call   80103890 <mycpu>
  p = c->proc;
80103ed9:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103edf:	e8 1c 05 00 00       	call   80104400 <popcli>
  if(p == 0)
80103ee4:	85 db                	test   %ebx,%ebx
80103ee6:	0f 84 87 00 00 00    	je     80103f73 <sleep+0xb3>
  if(lk == 0)
80103eec:	85 f6                	test   %esi,%esi
80103eee:	74 76                	je     80103f66 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103ef0:	81 fe 00 ae 15 88    	cmp    $0x8815ae00,%esi
80103ef6:	74 50                	je     80103f48 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103ef8:	83 ec 0c             	sub    $0xc,%esp
80103efb:	68 00 ae 15 88       	push   $0x8815ae00
80103f00:	e8 9b 05 00 00       	call   801044a0 <acquire>
    release(lk);
80103f05:	89 34 24             	mov    %esi,(%esp)
80103f08:	e8 53 06 00 00       	call   80104560 <release>
  p->chan = chan;
80103f0d:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80103f10:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103f17:	e8 64 fd ff ff       	call   80103c80 <sched>
  p->chan = 0;
80103f1c:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
    release(&ptable.lock);
80103f23:	c7 04 24 00 ae 15 88 	movl   $0x8815ae00,(%esp)
80103f2a:	e8 31 06 00 00       	call   80104560 <release>
    acquire(lk);
80103f2f:	89 75 08             	mov    %esi,0x8(%ebp)
80103f32:	83 c4 10             	add    $0x10,%esp
}
80103f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f38:	5b                   	pop    %ebx
80103f39:	5e                   	pop    %esi
80103f3a:	5f                   	pop    %edi
80103f3b:	5d                   	pop    %ebp
    acquire(lk);
80103f3c:	e9 5f 05 00 00       	jmp    801044a0 <acquire>
80103f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
80103f48:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80103f4b:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103f52:	e8 29 fd ff ff       	call   80103c80 <sched>
  p->chan = 0;
80103f57:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
80103f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f61:	5b                   	pop    %ebx
80103f62:	5e                   	pop    %esi
80103f63:	5f                   	pop    %edi
80103f64:	5d                   	pop    %ebp
80103f65:	c3                   	ret
    panic("sleep without lk");
80103f66:	83 ec 0c             	sub    $0xc,%esp
80103f69:	68 50 72 10 80       	push   $0x80107250
80103f6e:	e8 0d c4 ff ff       	call   80100380 <panic>
    panic("sleep");
80103f73:	83 ec 0c             	sub    $0xc,%esp
80103f76:	68 4a 72 10 80       	push   $0x8010724a
80103f7b:	e8 00 c4 ff ff       	call   80100380 <panic>

80103f80 <wait>:
{
80103f80:	55                   	push   %ebp
80103f81:	89 e5                	mov    %esp,%ebp
80103f83:	56                   	push   %esi
80103f84:	53                   	push   %ebx
  pushcli();
80103f85:	e8 26 04 00 00       	call   801043b0 <pushcli>
  c = mycpu();
80103f8a:	e8 01 f9 ff ff       	call   80103890 <mycpu>
  p = c->proc;
80103f8f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80103f95:	e8 66 04 00 00       	call   80104400 <popcli>
  acquire(&ptable.lock);
80103f9a:	83 ec 0c             	sub    $0xc,%esp
80103f9d:	68 00 ae 15 88       	push   $0x8815ae00
80103fa2:	e8 f9 04 00 00       	call   801044a0 <acquire>
80103fa7:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103faa:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fac:	bb 34 ae 15 88       	mov    $0x8815ae34,%ebx
80103fb1:	eb 10                	jmp    80103fc3 <wait+0x43>
80103fb3:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
80103fb8:	83 c3 7c             	add    $0x7c,%ebx
80103fbb:	81 fb 34 cd 15 88    	cmp    $0x8815cd34,%ebx
80103fc1:	74 1b                	je     80103fde <wait+0x5e>
      if(p->parent != curproc)
80103fc3:	39 73 14             	cmp    %esi,0x14(%ebx)
80103fc6:	75 f0                	jne    80103fb8 <wait+0x38>
      if(p->state == ZOMBIE){
80103fc8:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103fcc:	74 32                	je     80104000 <wait+0x80>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fce:	83 c3 7c             	add    $0x7c,%ebx
      havekids = 1;
80103fd1:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fd6:	81 fb 34 cd 15 88    	cmp    $0x8815cd34,%ebx
80103fdc:	75 e5                	jne    80103fc3 <wait+0x43>
    if(!havekids || curproc->killed){
80103fde:	85 c0                	test   %eax,%eax
80103fe0:	74 74                	je     80104056 <wait+0xd6>
80103fe2:	8b 46 24             	mov    0x24(%esi),%eax
80103fe5:	85 c0                	test   %eax,%eax
80103fe7:	75 6d                	jne    80104056 <wait+0xd6>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103fe9:	83 ec 08             	sub    $0x8,%esp
80103fec:	68 00 ae 15 88       	push   $0x8815ae00
80103ff1:	56                   	push   %esi
80103ff2:	e8 c9 fe ff ff       	call   80103ec0 <sleep>
    havekids = 0;
80103ff7:	83 c4 10             	add    $0x10,%esp
80103ffa:	eb ae                	jmp    80103faa <wait+0x2a>
80103ffc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        kfree(p->kstack);
80104000:	83 ec 0c             	sub    $0xc,%esp
80104003:	ff 73 08             	push   0x8(%ebx)
        pid = p->pid;
80104006:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80104009:	e8 92 e4 ff ff       	call   801024a0 <kfree>
        freevm(p->pgdir);
8010400e:	5a                   	pop    %edx
8010400f:	ff 73 04             	push   0x4(%ebx)
        p->kstack = 0;
80104012:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80104019:	e8 32 2c 00 00       	call   80106c50 <freevm>
        release(&ptable.lock);
8010401e:	c7 04 24 00 ae 15 88 	movl   $0x8815ae00,(%esp)
        p->pid = 0;
80104025:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
8010402c:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80104033:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80104037:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
8010403e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80104045:	e8 16 05 00 00       	call   80104560 <release>
        return pid;
8010404a:	83 c4 10             	add    $0x10,%esp
}
8010404d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104050:	89 f0                	mov    %esi,%eax
80104052:	5b                   	pop    %ebx
80104053:	5e                   	pop    %esi
80104054:	5d                   	pop    %ebp
80104055:	c3                   	ret
      release(&ptable.lock);
80104056:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104059:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
8010405e:	68 00 ae 15 88       	push   $0x8815ae00
80104063:	e8 f8 04 00 00       	call   80104560 <release>
      return -1;
80104068:	83 c4 10             	add    $0x10,%esp
8010406b:	eb e0                	jmp    8010404d <wait+0xcd>
8010406d:	8d 76 00             	lea    0x0(%esi),%esi

80104070 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104070:	55                   	push   %ebp
80104071:	89 e5                	mov    %esp,%ebp
80104073:	53                   	push   %ebx
80104074:	83 ec 10             	sub    $0x10,%esp
80104077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010407a:	68 00 ae 15 88       	push   $0x8815ae00
8010407f:	e8 1c 04 00 00       	call   801044a0 <acquire>
80104084:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104087:	b8 34 ae 15 88       	mov    $0x8815ae34,%eax
8010408c:	eb 0c                	jmp    8010409a <wakeup+0x2a>
8010408e:	66 90                	xchg   %ax,%ax
80104090:	83 c0 7c             	add    $0x7c,%eax
80104093:	3d 34 cd 15 88       	cmp    $0x8815cd34,%eax
80104098:	74 1c                	je     801040b6 <wakeup+0x46>
    if(p->state == SLEEPING && p->chan == chan)
8010409a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010409e:	75 f0                	jne    80104090 <wakeup+0x20>
801040a0:	3b 58 20             	cmp    0x20(%eax),%ebx
801040a3:	75 eb                	jne    80104090 <wakeup+0x20>
      p->state = RUNNABLE;
801040a5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801040ac:	83 c0 7c             	add    $0x7c,%eax
801040af:	3d 34 cd 15 88       	cmp    $0x8815cd34,%eax
801040b4:	75 e4                	jne    8010409a <wakeup+0x2a>
  wakeup1(chan);
  release(&ptable.lock);
801040b6:	c7 45 08 00 ae 15 88 	movl   $0x8815ae00,0x8(%ebp)
}
801040bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040c0:	c9                   	leave
  release(&ptable.lock);
801040c1:	e9 9a 04 00 00       	jmp    80104560 <release>
801040c6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801040cd:	00 
801040ce:	66 90                	xchg   %ax,%ax

801040d0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801040d0:	55                   	push   %ebp
801040d1:	89 e5                	mov    %esp,%ebp
801040d3:	53                   	push   %ebx
801040d4:	83 ec 10             	sub    $0x10,%esp
801040d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801040da:	68 00 ae 15 88       	push   $0x8815ae00
801040df:	e8 bc 03 00 00       	call   801044a0 <acquire>
801040e4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040e7:	b8 34 ae 15 88       	mov    $0x8815ae34,%eax
801040ec:	eb 0c                	jmp    801040fa <kill+0x2a>
801040ee:	66 90                	xchg   %ax,%ax
801040f0:	83 c0 7c             	add    $0x7c,%eax
801040f3:	3d 34 cd 15 88       	cmp    $0x8815cd34,%eax
801040f8:	74 36                	je     80104130 <kill+0x60>
    if(p->pid == pid){
801040fa:	39 58 10             	cmp    %ebx,0x10(%eax)
801040fd:	75 f1                	jne    801040f0 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801040ff:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
80104103:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010410a:	75 07                	jne    80104113 <kill+0x43>
        p->state = RUNNABLE;
8010410c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104113:	83 ec 0c             	sub    $0xc,%esp
80104116:	68 00 ae 15 88       	push   $0x8815ae00
8010411b:	e8 40 04 00 00       	call   80104560 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80104120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
80104123:	83 c4 10             	add    $0x10,%esp
80104126:	31 c0                	xor    %eax,%eax
}
80104128:	c9                   	leave
80104129:	c3                   	ret
8010412a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
80104130:	83 ec 0c             	sub    $0xc,%esp
80104133:	68 00 ae 15 88       	push   $0x8815ae00
80104138:	e8 23 04 00 00       	call   80104560 <release>
}
8010413d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104140:	83 c4 10             	add    $0x10,%esp
80104143:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104148:	c9                   	leave
80104149:	c3                   	ret
8010414a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104150 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104150:	55                   	push   %ebp
80104151:	89 e5                	mov    %esp,%ebp
80104153:	57                   	push   %edi
80104154:	56                   	push   %esi
80104155:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104158:	53                   	push   %ebx
80104159:	bb a0 ae 15 88       	mov    $0x8815aea0,%ebx
8010415e:	83 ec 3c             	sub    $0x3c,%esp
80104161:	eb 24                	jmp    80104187 <procdump+0x37>
80104163:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104168:	83 ec 0c             	sub    $0xc,%esp
8010416b:	68 0f 74 10 80       	push   $0x8010740f
80104170:	e8 3b c5 ff ff       	call   801006b0 <cprintf>
80104175:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104178:	83 c3 7c             	add    $0x7c,%ebx
8010417b:	81 fb a0 cd 15 88    	cmp    $0x8815cda0,%ebx
80104181:	0f 84 81 00 00 00    	je     80104208 <procdump+0xb8>
    if(p->state == UNUSED)
80104187:	8b 43 a0             	mov    -0x60(%ebx),%eax
8010418a:	85 c0                	test   %eax,%eax
8010418c:	74 ea                	je     80104178 <procdump+0x28>
      state = "???";
8010418e:	ba 61 72 10 80       	mov    $0x80107261,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104193:	83 f8 05             	cmp    $0x5,%eax
80104196:	77 11                	ja     801041a9 <procdump+0x59>
80104198:	8b 14 85 40 78 10 80 	mov    -0x7fef87c0(,%eax,4),%edx
      state = "???";
8010419f:	b8 61 72 10 80       	mov    $0x80107261,%eax
801041a4:	85 d2                	test   %edx,%edx
801041a6:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
801041a9:	53                   	push   %ebx
801041aa:	52                   	push   %edx
801041ab:	ff 73 a4             	push   -0x5c(%ebx)
801041ae:	68 65 72 10 80       	push   $0x80107265
801041b3:	e8 f8 c4 ff ff       	call   801006b0 <cprintf>
    if(p->state == SLEEPING){
801041b8:	83 c4 10             	add    $0x10,%esp
801041bb:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
801041bf:	75 a7                	jne    80104168 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801041c1:	83 ec 08             	sub    $0x8,%esp
801041c4:	8d 45 c0             	lea    -0x40(%ebp),%eax
801041c7:	8d 7d c0             	lea    -0x40(%ebp),%edi
801041ca:	50                   	push   %eax
801041cb:	8b 43 b0             	mov    -0x50(%ebx),%eax
801041ce:	8b 40 0c             	mov    0xc(%eax),%eax
801041d1:	83 c0 08             	add    $0x8,%eax
801041d4:	50                   	push   %eax
801041d5:	e8 86 01 00 00       	call   80104360 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801041da:	83 c4 10             	add    $0x10,%esp
801041dd:	8d 76 00             	lea    0x0(%esi),%esi
801041e0:	8b 17                	mov    (%edi),%edx
801041e2:	85 d2                	test   %edx,%edx
801041e4:	74 82                	je     80104168 <procdump+0x18>
        cprintf(" %p", pc[i]);
801041e6:	83 ec 08             	sub    $0x8,%esp
801041e9:	83 c7 04             	add    $0x4,%edi
801041ec:	52                   	push   %edx
801041ed:	68 a1 6f 10 80       	push   $0x80106fa1
801041f2:	e8 b9 c4 ff ff       	call   801006b0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
801041f7:	83 c4 10             	add    $0x10,%esp
801041fa:	39 fe                	cmp    %edi,%esi
801041fc:	75 e2                	jne    801041e0 <procdump+0x90>
801041fe:	e9 65 ff ff ff       	jmp    80104168 <procdump+0x18>
80104203:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
  }
}
80104208:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010420b:	5b                   	pop    %ebx
8010420c:	5e                   	pop    %esi
8010420d:	5f                   	pop    %edi
8010420e:	5d                   	pop    %ebp
8010420f:	c3                   	ret

80104210 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104210:	55                   	push   %ebp
80104211:	89 e5                	mov    %esp,%ebp
80104213:	53                   	push   %ebx
80104214:	83 ec 0c             	sub    $0xc,%esp
80104217:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010421a:	68 98 72 10 80       	push   $0x80107298
8010421f:	8d 43 04             	lea    0x4(%ebx),%eax
80104222:	50                   	push   %eax
80104223:	e8 18 01 00 00       	call   80104340 <initlock>
  lk->name = name;
80104228:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
8010422b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
80104231:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
80104234:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
8010423b:	89 43 38             	mov    %eax,0x38(%ebx)
}
8010423e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104241:	c9                   	leave
80104242:	c3                   	ret
80104243:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010424a:	00 
8010424b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80104250 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104250:	55                   	push   %ebp
80104251:	89 e5                	mov    %esp,%ebp
80104253:	56                   	push   %esi
80104254:	53                   	push   %ebx
80104255:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104258:	8d 73 04             	lea    0x4(%ebx),%esi
8010425b:	83 ec 0c             	sub    $0xc,%esp
8010425e:	56                   	push   %esi
8010425f:	e8 3c 02 00 00       	call   801044a0 <acquire>
  while (lk->locked) {
80104264:	8b 13                	mov    (%ebx),%edx
80104266:	83 c4 10             	add    $0x10,%esp
80104269:	85 d2                	test   %edx,%edx
8010426b:	74 16                	je     80104283 <acquiresleep+0x33>
8010426d:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
80104270:	83 ec 08             	sub    $0x8,%esp
80104273:	56                   	push   %esi
80104274:	53                   	push   %ebx
80104275:	e8 46 fc ff ff       	call   80103ec0 <sleep>
  while (lk->locked) {
8010427a:	8b 03                	mov    (%ebx),%eax
8010427c:	83 c4 10             	add    $0x10,%esp
8010427f:	85 c0                	test   %eax,%eax
80104281:	75 ed                	jne    80104270 <acquiresleep+0x20>
  }
  lk->locked = 1;
80104283:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104289:	e8 92 f6 ff ff       	call   80103920 <myproc>
8010428e:	8b 40 10             	mov    0x10(%eax),%eax
80104291:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80104294:	89 75 08             	mov    %esi,0x8(%ebp)
}
80104297:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010429a:	5b                   	pop    %ebx
8010429b:	5e                   	pop    %esi
8010429c:	5d                   	pop    %ebp
  release(&lk->lk);
8010429d:	e9 be 02 00 00       	jmp    80104560 <release>
801042a2:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801042a9:	00 
801042aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801042b0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801042b0:	55                   	push   %ebp
801042b1:	89 e5                	mov    %esp,%ebp
801042b3:	56                   	push   %esi
801042b4:	53                   	push   %ebx
801042b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801042b8:	8d 73 04             	lea    0x4(%ebx),%esi
801042bb:	83 ec 0c             	sub    $0xc,%esp
801042be:	56                   	push   %esi
801042bf:	e8 dc 01 00 00       	call   801044a0 <acquire>
  lk->locked = 0;
801042c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801042ca:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
801042d1:	89 1c 24             	mov    %ebx,(%esp)
801042d4:	e8 97 fd ff ff       	call   80104070 <wakeup>
  release(&lk->lk);
801042d9:	89 75 08             	mov    %esi,0x8(%ebp)
801042dc:	83 c4 10             	add    $0x10,%esp
}
801042df:	8d 65 f8             	lea    -0x8(%ebp),%esp
801042e2:	5b                   	pop    %ebx
801042e3:	5e                   	pop    %esi
801042e4:	5d                   	pop    %ebp
  release(&lk->lk);
801042e5:	e9 76 02 00 00       	jmp    80104560 <release>
801042ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801042f0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801042f0:	55                   	push   %ebp
801042f1:	89 e5                	mov    %esp,%ebp
801042f3:	57                   	push   %edi
801042f4:	31 ff                	xor    %edi,%edi
801042f6:	56                   	push   %esi
801042f7:	53                   	push   %ebx
801042f8:	83 ec 18             	sub    $0x18,%esp
801042fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
801042fe:	8d 73 04             	lea    0x4(%ebx),%esi
80104301:	56                   	push   %esi
80104302:	e8 99 01 00 00       	call   801044a0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80104307:	8b 03                	mov    (%ebx),%eax
80104309:	83 c4 10             	add    $0x10,%esp
8010430c:	85 c0                	test   %eax,%eax
8010430e:	75 18                	jne    80104328 <holdingsleep+0x38>
  release(&lk->lk);
80104310:	83 ec 0c             	sub    $0xc,%esp
80104313:	56                   	push   %esi
80104314:	e8 47 02 00 00       	call   80104560 <release>
  return r;
}
80104319:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010431c:	89 f8                	mov    %edi,%eax
8010431e:	5b                   	pop    %ebx
8010431f:	5e                   	pop    %esi
80104320:	5f                   	pop    %edi
80104321:	5d                   	pop    %ebp
80104322:	c3                   	ret
80104323:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
  r = lk->locked && (lk->pid == myproc()->pid);
80104328:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
8010432b:	e8 f0 f5 ff ff       	call   80103920 <myproc>
80104330:	39 58 10             	cmp    %ebx,0x10(%eax)
80104333:	0f 94 c0             	sete   %al
80104336:	0f b6 c0             	movzbl %al,%eax
80104339:	89 c7                	mov    %eax,%edi
8010433b:	eb d3                	jmp    80104310 <holdingsleep+0x20>
8010433d:	66 90                	xchg   %ax,%ax
8010433f:	90                   	nop

80104340 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80104340:	55                   	push   %ebp
80104341:	89 e5                	mov    %esp,%ebp
80104343:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104346:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
80104349:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
8010434f:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
80104352:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104359:	5d                   	pop    %ebp
8010435a:	c3                   	ret
8010435b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80104360 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104360:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104361:	31 d2                	xor    %edx,%edx
{
80104363:	89 e5                	mov    %esp,%ebp
80104365:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104366:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104369:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
8010436c:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
8010436f:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104370:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104376:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
8010437c:	77 1a                	ja     80104398 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010437e:	8b 58 04             	mov    0x4(%eax),%ebx
80104381:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104384:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104387:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104389:	83 fa 0a             	cmp    $0xa,%edx
8010438c:	75 e2                	jne    80104370 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
8010438e:	5b                   	pop    %ebx
8010438f:	5d                   	pop    %ebp
80104390:	c3                   	ret
80104391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
80104398:	8d 04 91             	lea    (%ecx,%edx,4),%eax
8010439b:	8d 51 28             	lea    0x28(%ecx),%edx
8010439e:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
801043a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801043a6:	83 c0 04             	add    $0x4,%eax
801043a9:	39 d0                	cmp    %edx,%eax
801043ab:	75 f3                	jne    801043a0 <getcallerpcs+0x40>
}
801043ad:	5b                   	pop    %ebx
801043ae:	5d                   	pop    %ebp
801043af:	c3                   	ret

801043b0 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801043b0:	55                   	push   %ebp
801043b1:	89 e5                	mov    %esp,%ebp
801043b3:	53                   	push   %ebx
801043b4:	83 ec 04             	sub    $0x4,%esp
801043b7:	9c                   	pushf
801043b8:	5b                   	pop    %ebx
  asm volatile("cli");
801043b9:	fa                   	cli
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
801043ba:	e8 d1 f4 ff ff       	call   80103890 <mycpu>
801043bf:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801043c5:	85 c0                	test   %eax,%eax
801043c7:	74 17                	je     801043e0 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
801043c9:	e8 c2 f4 ff ff       	call   80103890 <mycpu>
801043ce:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
801043d5:	83 c4 04             	add    $0x4,%esp
801043d8:	5b                   	pop    %ebx
801043d9:	5d                   	pop    %ebp
801043da:	c3                   	ret
801043db:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
    mycpu()->intena = eflags & FL_IF;
801043e0:	e8 ab f4 ff ff       	call   80103890 <mycpu>
801043e5:	81 e3 00 02 00 00    	and    $0x200,%ebx
801043eb:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
801043f1:	eb d6                	jmp    801043c9 <pushcli+0x19>
801043f3:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801043fa:	00 
801043fb:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80104400 <popcli>:

void
popcli(void)
{
80104400:	55                   	push   %ebp
80104401:	89 e5                	mov    %esp,%ebp
80104403:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104406:	9c                   	pushf
80104407:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104408:	f6 c4 02             	test   $0x2,%ah
8010440b:	75 35                	jne    80104442 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
8010440d:	e8 7e f4 ff ff       	call   80103890 <mycpu>
80104412:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104419:	78 34                	js     8010444f <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010441b:	e8 70 f4 ff ff       	call   80103890 <mycpu>
80104420:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104426:	85 d2                	test   %edx,%edx
80104428:	74 06                	je     80104430 <popcli+0x30>
    sti();
}
8010442a:	c9                   	leave
8010442b:	c3                   	ret
8010442c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104430:	e8 5b f4 ff ff       	call   80103890 <mycpu>
80104435:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010443b:	85 c0                	test   %eax,%eax
8010443d:	74 eb                	je     8010442a <popcli+0x2a>
  asm volatile("sti");
8010443f:	fb                   	sti
}
80104440:	c9                   	leave
80104441:	c3                   	ret
    panic("popcli - interruptible");
80104442:	83 ec 0c             	sub    $0xc,%esp
80104445:	68 a3 72 10 80       	push   $0x801072a3
8010444a:	e8 31 bf ff ff       	call   80100380 <panic>
    panic("popcli");
8010444f:	83 ec 0c             	sub    $0xc,%esp
80104452:	68 ba 72 10 80       	push   $0x801072ba
80104457:	e8 24 bf ff ff       	call   80100380 <panic>
8010445c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104460 <holding>:
{
80104460:	55                   	push   %ebp
80104461:	89 e5                	mov    %esp,%ebp
80104463:	56                   	push   %esi
80104464:	53                   	push   %ebx
80104465:	8b 75 08             	mov    0x8(%ebp),%esi
80104468:	31 db                	xor    %ebx,%ebx
  pushcli();
8010446a:	e8 41 ff ff ff       	call   801043b0 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
8010446f:	8b 06                	mov    (%esi),%eax
80104471:	85 c0                	test   %eax,%eax
80104473:	75 0b                	jne    80104480 <holding+0x20>
  popcli();
80104475:	e8 86 ff ff ff       	call   80104400 <popcli>
}
8010447a:	89 d8                	mov    %ebx,%eax
8010447c:	5b                   	pop    %ebx
8010447d:	5e                   	pop    %esi
8010447e:	5d                   	pop    %ebp
8010447f:	c3                   	ret
  r = lock->locked && lock->cpu == mycpu();
80104480:	8b 5e 08             	mov    0x8(%esi),%ebx
80104483:	e8 08 f4 ff ff       	call   80103890 <mycpu>
80104488:	39 c3                	cmp    %eax,%ebx
8010448a:	0f 94 c3             	sete   %bl
  popcli();
8010448d:	e8 6e ff ff ff       	call   80104400 <popcli>
  r = lock->locked && lock->cpu == mycpu();
80104492:	0f b6 db             	movzbl %bl,%ebx
}
80104495:	89 d8                	mov    %ebx,%eax
80104497:	5b                   	pop    %ebx
80104498:	5e                   	pop    %esi
80104499:	5d                   	pop    %ebp
8010449a:	c3                   	ret
8010449b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

801044a0 <acquire>:
{
801044a0:	55                   	push   %ebp
801044a1:	89 e5                	mov    %esp,%ebp
801044a3:	56                   	push   %esi
801044a4:	53                   	push   %ebx
  pushcli(); // disable interrupts to avoid deadlock.
801044a5:	e8 06 ff ff ff       	call   801043b0 <pushcli>
  if(holding(lk))
801044aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
801044ad:	83 ec 0c             	sub    $0xc,%esp
801044b0:	53                   	push   %ebx
801044b1:	e8 aa ff ff ff       	call   80104460 <holding>
801044b6:	83 c4 10             	add    $0x10,%esp
801044b9:	85 c0                	test   %eax,%eax
801044bb:	0f 85 83 00 00 00    	jne    80104544 <acquire+0xa4>
801044c1:	89 c6                	mov    %eax,%esi
  asm volatile("lock; xchgl %0, %1" :
801044c3:	ba 01 00 00 00       	mov    $0x1,%edx
801044c8:	eb 09                	jmp    801044d3 <acquire+0x33>
801044ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801044d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
801044d3:	89 d0                	mov    %edx,%eax
801044d5:	f0 87 03             	lock xchg %eax,(%ebx)
  while(xchg(&lk->locked, 1) != 0)
801044d8:	85 c0                	test   %eax,%eax
801044da:	75 f4                	jne    801044d0 <acquire+0x30>
  __sync_synchronize();
801044dc:	0f ae f0             	mfence
  lk->cpu = mycpu();
801044df:	8b 5d 08             	mov    0x8(%ebp),%ebx
801044e2:	e8 a9 f3 ff ff       	call   80103890 <mycpu>
801044e7:	89 43 08             	mov    %eax,0x8(%ebx)
  ebp = (uint*)v - 2;
801044ea:	89 e8                	mov    %ebp,%eax
801044ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801044f0:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801044f6:	81 fa fe ff ff 7f    	cmp    $0x7ffffffe,%edx
801044fc:	77 22                	ja     80104520 <acquire+0x80>
    pcs[i] = ebp[1];     // saved %eip
801044fe:	8b 50 04             	mov    0x4(%eax),%edx
80104501:	89 54 b3 0c          	mov    %edx,0xc(%ebx,%esi,4)
  for(i = 0; i < 10; i++){
80104505:	83 c6 01             	add    $0x1,%esi
    ebp = (uint*)ebp[0]; // saved %ebp
80104508:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
8010450a:	83 fe 0a             	cmp    $0xa,%esi
8010450d:	75 e1                	jne    801044f0 <acquire+0x50>
}
8010450f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104512:	5b                   	pop    %ebx
80104513:	5e                   	pop    %esi
80104514:	5d                   	pop    %ebp
80104515:	c3                   	ret
80104516:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010451d:	00 
8010451e:	66 90                	xchg   %ax,%ax
  for(; i < 10; i++)
80104520:	8d 44 b3 0c          	lea    0xc(%ebx,%esi,4),%eax
80104524:	83 c3 34             	add    $0x34,%ebx
80104527:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010452e:	00 
8010452f:	90                   	nop
    pcs[i] = 0;
80104530:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104536:	83 c0 04             	add    $0x4,%eax
80104539:	39 d8                	cmp    %ebx,%eax
8010453b:	75 f3                	jne    80104530 <acquire+0x90>
}
8010453d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104540:	5b                   	pop    %ebx
80104541:	5e                   	pop    %esi
80104542:	5d                   	pop    %ebp
80104543:	c3                   	ret
    panic("acquire");
80104544:	83 ec 0c             	sub    $0xc,%esp
80104547:	68 c1 72 10 80       	push   $0x801072c1
8010454c:	e8 2f be ff ff       	call   80100380 <panic>
80104551:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104558:	00 
80104559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104560 <release>:
{
80104560:	55                   	push   %ebp
80104561:	89 e5                	mov    %esp,%ebp
80104563:	53                   	push   %ebx
80104564:	83 ec 10             	sub    $0x10,%esp
80104567:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
8010456a:	53                   	push   %ebx
8010456b:	e8 f0 fe ff ff       	call   80104460 <holding>
80104570:	83 c4 10             	add    $0x10,%esp
80104573:	85 c0                	test   %eax,%eax
80104575:	74 20                	je     80104597 <release+0x37>
  lk->pcs[0] = 0;
80104577:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
8010457e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104585:	0f ae f0             	mfence
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104588:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
8010458e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104591:	c9                   	leave
  popcli();
80104592:	e9 69 fe ff ff       	jmp    80104400 <popcli>
    panic("release");
80104597:	83 ec 0c             	sub    $0xc,%esp
8010459a:	68 c9 72 10 80       	push   $0x801072c9
8010459f:	e8 dc bd ff ff       	call   80100380 <panic>
801045a4:	66 90                	xchg   %ax,%ax
801045a6:	66 90                	xchg   %ax,%ax
801045a8:	66 90                	xchg   %ax,%ax
801045aa:	66 90                	xchg   %ax,%ax
801045ac:	66 90                	xchg   %ax,%ax
801045ae:	66 90                	xchg   %ax,%ax

801045b0 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801045b0:	55                   	push   %ebp
801045b1:	89 e5                	mov    %esp,%ebp
801045b3:	57                   	push   %edi
801045b4:	8b 55 08             	mov    0x8(%ebp),%edx
801045b7:	8b 4d 10             	mov    0x10(%ebp),%ecx
801045ba:	53                   	push   %ebx
801045bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
801045be:	89 d7                	mov    %edx,%edi
801045c0:	09 cf                	or     %ecx,%edi
801045c2:	83 e7 03             	and    $0x3,%edi
801045c5:	75 29                	jne    801045f0 <memset+0x40>
    c &= 0xFF;
801045c7:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801045ca:	c1 e0 18             	shl    $0x18,%eax
801045cd:	89 fb                	mov    %edi,%ebx
801045cf:	c1 e9 02             	shr    $0x2,%ecx
801045d2:	c1 e3 10             	shl    $0x10,%ebx
801045d5:	09 d8                	or     %ebx,%eax
801045d7:	09 f8                	or     %edi,%eax
801045d9:	c1 e7 08             	shl    $0x8,%edi
801045dc:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
801045de:	89 d7                	mov    %edx,%edi
801045e0:	fc                   	cld
801045e1:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
801045e3:	5b                   	pop    %ebx
801045e4:	89 d0                	mov    %edx,%eax
801045e6:	5f                   	pop    %edi
801045e7:	5d                   	pop    %ebp
801045e8:	c3                   	ret
801045e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("cld; rep stosb" :
801045f0:	89 d7                	mov    %edx,%edi
801045f2:	fc                   	cld
801045f3:	f3 aa                	rep stos %al,%es:(%edi)
801045f5:	5b                   	pop    %ebx
801045f6:	89 d0                	mov    %edx,%eax
801045f8:	5f                   	pop    %edi
801045f9:	5d                   	pop    %ebp
801045fa:	c3                   	ret
801045fb:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80104600 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104600:	55                   	push   %ebp
80104601:	89 e5                	mov    %esp,%ebp
80104603:	56                   	push   %esi
80104604:	8b 75 10             	mov    0x10(%ebp),%esi
80104607:	8b 55 08             	mov    0x8(%ebp),%edx
8010460a:	53                   	push   %ebx
8010460b:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010460e:	85 f6                	test   %esi,%esi
80104610:	74 2e                	je     80104640 <memcmp+0x40>
80104612:	01 c6                	add    %eax,%esi
80104614:	eb 14                	jmp    8010462a <memcmp+0x2a>
80104616:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010461d:	00 
8010461e:	66 90                	xchg   %ax,%ax
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104620:	83 c0 01             	add    $0x1,%eax
80104623:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104626:	39 f0                	cmp    %esi,%eax
80104628:	74 16                	je     80104640 <memcmp+0x40>
    if(*s1 != *s2)
8010462a:	0f b6 0a             	movzbl (%edx),%ecx
8010462d:	0f b6 18             	movzbl (%eax),%ebx
80104630:	38 d9                	cmp    %bl,%cl
80104632:	74 ec                	je     80104620 <memcmp+0x20>
      return *s1 - *s2;
80104634:	0f b6 c1             	movzbl %cl,%eax
80104637:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104639:	5b                   	pop    %ebx
8010463a:	5e                   	pop    %esi
8010463b:	5d                   	pop    %ebp
8010463c:	c3                   	ret
8010463d:	8d 76 00             	lea    0x0(%esi),%esi
80104640:	5b                   	pop    %ebx
  return 0;
80104641:	31 c0                	xor    %eax,%eax
}
80104643:	5e                   	pop    %esi
80104644:	5d                   	pop    %ebp
80104645:	c3                   	ret
80104646:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010464d:	00 
8010464e:	66 90                	xchg   %ax,%ax

80104650 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104650:	55                   	push   %ebp
80104651:	89 e5                	mov    %esp,%ebp
80104653:	57                   	push   %edi
80104654:	8b 55 08             	mov    0x8(%ebp),%edx
80104657:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010465a:	56                   	push   %esi
8010465b:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010465e:	39 d6                	cmp    %edx,%esi
80104660:	73 26                	jae    80104688 <memmove+0x38>
80104662:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
80104665:	39 fa                	cmp    %edi,%edx
80104667:	73 1f                	jae    80104688 <memmove+0x38>
80104669:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
8010466c:	85 c9                	test   %ecx,%ecx
8010466e:	74 0f                	je     8010467f <memmove+0x2f>
      *--d = *--s;
80104670:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80104674:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80104677:	83 e8 01             	sub    $0x1,%eax
8010467a:	83 f8 ff             	cmp    $0xffffffff,%eax
8010467d:	75 f1                	jne    80104670 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
8010467f:	5e                   	pop    %esi
80104680:	89 d0                	mov    %edx,%eax
80104682:	5f                   	pop    %edi
80104683:	5d                   	pop    %ebp
80104684:	c3                   	ret
80104685:	8d 76 00             	lea    0x0(%esi),%esi
    while(n-- > 0)
80104688:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
8010468b:	89 d7                	mov    %edx,%edi
8010468d:	85 c9                	test   %ecx,%ecx
8010468f:	74 ee                	je     8010467f <memmove+0x2f>
80104691:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80104698:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80104699:	39 f0                	cmp    %esi,%eax
8010469b:	75 fb                	jne    80104698 <memmove+0x48>
}
8010469d:	5e                   	pop    %esi
8010469e:	89 d0                	mov    %edx,%eax
801046a0:	5f                   	pop    %edi
801046a1:	5d                   	pop    %ebp
801046a2:	c3                   	ret
801046a3:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801046aa:	00 
801046ab:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

801046b0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
801046b0:	eb 9e                	jmp    80104650 <memmove>
801046b2:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801046b9:	00 
801046ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801046c0 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
801046c0:	55                   	push   %ebp
801046c1:	89 e5                	mov    %esp,%ebp
801046c3:	56                   	push   %esi
801046c4:	8b 75 10             	mov    0x10(%ebp),%esi
801046c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046ca:	53                   	push   %ebx
801046cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  while(n > 0 && *p && *p == *q)
801046ce:	85 f6                	test   %esi,%esi
801046d0:	74 36                	je     80104708 <strncmp+0x48>
801046d2:	01 c6                	add    %eax,%esi
801046d4:	eb 18                	jmp    801046ee <strncmp+0x2e>
801046d6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801046dd:	00 
801046de:	66 90                	xchg   %ax,%ax
801046e0:	38 da                	cmp    %bl,%dl
801046e2:	75 14                	jne    801046f8 <strncmp+0x38>
    n--, p++, q++;
801046e4:	83 c0 01             	add    $0x1,%eax
801046e7:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
801046ea:	39 f0                	cmp    %esi,%eax
801046ec:	74 1a                	je     80104708 <strncmp+0x48>
801046ee:	0f b6 11             	movzbl (%ecx),%edx
801046f1:	0f b6 18             	movzbl (%eax),%ebx
801046f4:	84 d2                	test   %dl,%dl
801046f6:	75 e8                	jne    801046e0 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
801046f8:	0f b6 c2             	movzbl %dl,%eax
801046fb:	29 d8                	sub    %ebx,%eax
}
801046fd:	5b                   	pop    %ebx
801046fe:	5e                   	pop    %esi
801046ff:	5d                   	pop    %ebp
80104700:	c3                   	ret
80104701:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104708:	5b                   	pop    %ebx
    return 0;
80104709:	31 c0                	xor    %eax,%eax
}
8010470b:	5e                   	pop    %esi
8010470c:	5d                   	pop    %ebp
8010470d:	c3                   	ret
8010470e:	66 90                	xchg   %ax,%ax

80104710 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104710:	55                   	push   %ebp
80104711:	89 e5                	mov    %esp,%ebp
80104713:	57                   	push   %edi
80104714:	56                   	push   %esi
80104715:	8b 75 08             	mov    0x8(%ebp),%esi
80104718:	53                   	push   %ebx
80104719:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010471c:	89 f2                	mov    %esi,%edx
8010471e:	eb 17                	jmp    80104737 <strncpy+0x27>
80104720:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104724:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104727:	83 c2 01             	add    $0x1,%edx
8010472a:	0f b6 7f ff          	movzbl -0x1(%edi),%edi
8010472e:	89 f9                	mov    %edi,%ecx
80104730:	88 4a ff             	mov    %cl,-0x1(%edx)
80104733:	84 c9                	test   %cl,%cl
80104735:	74 09                	je     80104740 <strncpy+0x30>
80104737:	89 c3                	mov    %eax,%ebx
80104739:	83 e8 01             	sub    $0x1,%eax
8010473c:	85 db                	test   %ebx,%ebx
8010473e:	7f e0                	jg     80104720 <strncpy+0x10>
    ;
  while(n-- > 0)
80104740:	89 d1                	mov    %edx,%ecx
80104742:	85 c0                	test   %eax,%eax
80104744:	7e 1d                	jle    80104763 <strncpy+0x53>
80104746:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010474d:	00 
8010474e:	66 90                	xchg   %ax,%ax
    *s++ = 0;
80104750:	83 c1 01             	add    $0x1,%ecx
80104753:	c6 41 ff 00          	movb   $0x0,-0x1(%ecx)
  while(n-- > 0)
80104757:	89 c8                	mov    %ecx,%eax
80104759:	f7 d0                	not    %eax
8010475b:	01 d0                	add    %edx,%eax
8010475d:	01 d8                	add    %ebx,%eax
8010475f:	85 c0                	test   %eax,%eax
80104761:	7f ed                	jg     80104750 <strncpy+0x40>
  return os;
}
80104763:	5b                   	pop    %ebx
80104764:	89 f0                	mov    %esi,%eax
80104766:	5e                   	pop    %esi
80104767:	5f                   	pop    %edi
80104768:	5d                   	pop    %ebp
80104769:	c3                   	ret
8010476a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104770 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104770:	55                   	push   %ebp
80104771:	89 e5                	mov    %esp,%ebp
80104773:	56                   	push   %esi
80104774:	8b 55 10             	mov    0x10(%ebp),%edx
80104777:	8b 75 08             	mov    0x8(%ebp),%esi
8010477a:	53                   	push   %ebx
8010477b:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
8010477e:	85 d2                	test   %edx,%edx
80104780:	7e 25                	jle    801047a7 <safestrcpy+0x37>
80104782:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104786:	89 f2                	mov    %esi,%edx
80104788:	eb 16                	jmp    801047a0 <safestrcpy+0x30>
8010478a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104790:	0f b6 08             	movzbl (%eax),%ecx
80104793:	83 c0 01             	add    $0x1,%eax
80104796:	83 c2 01             	add    $0x1,%edx
80104799:	88 4a ff             	mov    %cl,-0x1(%edx)
8010479c:	84 c9                	test   %cl,%cl
8010479e:	74 04                	je     801047a4 <safestrcpy+0x34>
801047a0:	39 d8                	cmp    %ebx,%eax
801047a2:	75 ec                	jne    80104790 <safestrcpy+0x20>
    ;
  *s = 0;
801047a4:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
801047a7:	89 f0                	mov    %esi,%eax
801047a9:	5b                   	pop    %ebx
801047aa:	5e                   	pop    %esi
801047ab:	5d                   	pop    %ebp
801047ac:	c3                   	ret
801047ad:	8d 76 00             	lea    0x0(%esi),%esi

801047b0 <strlen>:

int
strlen(const char *s)
{
801047b0:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
801047b1:	31 c0                	xor    %eax,%eax
{
801047b3:	89 e5                	mov    %esp,%ebp
801047b5:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
801047b8:	80 3a 00             	cmpb   $0x0,(%edx)
801047bb:	74 0c                	je     801047c9 <strlen+0x19>
801047bd:	8d 76 00             	lea    0x0(%esi),%esi
801047c0:	83 c0 01             	add    $0x1,%eax
801047c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801047c7:	75 f7                	jne    801047c0 <strlen+0x10>
    ;
  return n;
}
801047c9:	5d                   	pop    %ebp
801047ca:	c3                   	ret

801047cb <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801047cb:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801047cf:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801047d3:	55                   	push   %ebp
  pushl %ebx
801047d4:	53                   	push   %ebx
  pushl %esi
801047d5:	56                   	push   %esi
  pushl %edi
801047d6:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801047d7:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801047d9:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801047db:	5f                   	pop    %edi
  popl %esi
801047dc:	5e                   	pop    %esi
  popl %ebx
801047dd:	5b                   	pop    %ebx
  popl %ebp
801047de:	5d                   	pop    %ebp
  ret
801047df:	c3                   	ret

801047e0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801047e0:	55                   	push   %ebp
801047e1:	89 e5                	mov    %esp,%ebp
801047e3:	53                   	push   %ebx
801047e4:	83 ec 04             	sub    $0x4,%esp
801047e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801047ea:	e8 31 f1 ff ff       	call   80103920 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801047ef:	8b 00                	mov    (%eax),%eax
801047f1:	39 d8                	cmp    %ebx,%eax
801047f3:	76 1b                	jbe    80104810 <fetchint+0x30>
801047f5:	8d 53 04             	lea    0x4(%ebx),%edx
801047f8:	39 d0                	cmp    %edx,%eax
801047fa:	72 14                	jb     80104810 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
801047fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801047ff:	8b 13                	mov    (%ebx),%edx
80104801:	89 10                	mov    %edx,(%eax)
  return 0;
80104803:	31 c0                	xor    %eax,%eax
}
80104805:	83 c4 04             	add    $0x4,%esp
80104808:	5b                   	pop    %ebx
80104809:	5d                   	pop    %ebp
8010480a:	c3                   	ret
8010480b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
    return -1;
80104810:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104815:	eb ee                	jmp    80104805 <fetchint+0x25>
80104817:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010481e:	00 
8010481f:	90                   	nop

80104820 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104820:	55                   	push   %ebp
80104821:	89 e5                	mov    %esp,%ebp
80104823:	53                   	push   %ebx
80104824:	83 ec 04             	sub    $0x4,%esp
80104827:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
8010482a:	e8 f1 f0 ff ff       	call   80103920 <myproc>

  if(addr >= curproc->sz)
8010482f:	39 18                	cmp    %ebx,(%eax)
80104831:	76 2d                	jbe    80104860 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
80104833:	8b 55 0c             	mov    0xc(%ebp),%edx
80104836:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104838:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
8010483a:	39 d3                	cmp    %edx,%ebx
8010483c:	73 22                	jae    80104860 <fetchstr+0x40>
8010483e:	89 d8                	mov    %ebx,%eax
80104840:	eb 0d                	jmp    8010484f <fetchstr+0x2f>
80104842:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104848:	83 c0 01             	add    $0x1,%eax
8010484b:	39 c2                	cmp    %eax,%edx
8010484d:	76 11                	jbe    80104860 <fetchstr+0x40>
    if(*s == 0)
8010484f:	80 38 00             	cmpb   $0x0,(%eax)
80104852:	75 f4                	jne    80104848 <fetchstr+0x28>
      return s - *pp;
  }
  return -1;
}
80104854:	83 c4 04             	add    $0x4,%esp
      return s - *pp;
80104857:	29 d8                	sub    %ebx,%eax
}
80104859:	5b                   	pop    %ebx
8010485a:	5d                   	pop    %ebp
8010485b:	c3                   	ret
8010485c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104860:	83 c4 04             	add    $0x4,%esp
    return -1;
80104863:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104868:	5b                   	pop    %ebx
80104869:	5d                   	pop    %ebp
8010486a:	c3                   	ret
8010486b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80104870 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104870:	55                   	push   %ebp
80104871:	89 e5                	mov    %esp,%ebp
80104873:	56                   	push   %esi
80104874:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104875:	e8 a6 f0 ff ff       	call   80103920 <myproc>
8010487a:	8b 55 08             	mov    0x8(%ebp),%edx
8010487d:	8b 40 18             	mov    0x18(%eax),%eax
80104880:	8b 40 44             	mov    0x44(%eax),%eax
80104883:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104886:	e8 95 f0 ff ff       	call   80103920 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010488b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010488e:	8b 00                	mov    (%eax),%eax
80104890:	39 c6                	cmp    %eax,%esi
80104892:	73 1c                	jae    801048b0 <argint+0x40>
80104894:	8d 53 08             	lea    0x8(%ebx),%edx
80104897:	39 d0                	cmp    %edx,%eax
80104899:	72 15                	jb     801048b0 <argint+0x40>
  *ip = *(int*)(addr);
8010489b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010489e:	8b 53 04             	mov    0x4(%ebx),%edx
801048a1:	89 10                	mov    %edx,(%eax)
  return 0;
801048a3:	31 c0                	xor    %eax,%eax
}
801048a5:	5b                   	pop    %ebx
801048a6:	5e                   	pop    %esi
801048a7:	5d                   	pop    %ebp
801048a8:	c3                   	ret
801048a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801048b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801048b5:	eb ee                	jmp    801048a5 <argint+0x35>
801048b7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801048be:	00 
801048bf:	90                   	nop

801048c0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801048c0:	55                   	push   %ebp
801048c1:	89 e5                	mov    %esp,%ebp
801048c3:	56                   	push   %esi
801048c4:	53                   	push   %ebx
801048c5:	83 ec 10             	sub    $0x10,%esp
801048c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
801048cb:	e8 50 f0 ff ff       	call   80103920 <myproc>
 
  if(argint(n, &i) < 0)
801048d0:	83 ec 08             	sub    $0x8,%esp
  struct proc *curproc = myproc();
801048d3:	89 c6                	mov    %eax,%esi
  if(argint(n, &i) < 0)
801048d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048d8:	50                   	push   %eax
801048d9:	ff 75 08             	push   0x8(%ebp)
801048dc:	e8 8f ff ff ff       	call   80104870 <argint>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801048e1:	83 c4 10             	add    $0x10,%esp
801048e4:	85 c0                	test   %eax,%eax
801048e6:	78 28                	js     80104910 <argptr+0x50>
801048e8:	85 db                	test   %ebx,%ebx
801048ea:	78 24                	js     80104910 <argptr+0x50>
801048ec:	8b 16                	mov    (%esi),%edx
801048ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f1:	39 c2                	cmp    %eax,%edx
801048f3:	76 1b                	jbe    80104910 <argptr+0x50>
801048f5:	01 c3                	add    %eax,%ebx
801048f7:	39 da                	cmp    %ebx,%edx
801048f9:	72 15                	jb     80104910 <argptr+0x50>
    return -1;
  *pp = (char*)i;
801048fb:	8b 55 0c             	mov    0xc(%ebp),%edx
801048fe:	89 02                	mov    %eax,(%edx)
  return 0;
80104900:	31 c0                	xor    %eax,%eax
}
80104902:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104905:	5b                   	pop    %ebx
80104906:	5e                   	pop    %esi
80104907:	5d                   	pop    %ebp
80104908:	c3                   	ret
80104909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104910:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104915:	eb eb                	jmp    80104902 <argptr+0x42>
80104917:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010491e:	00 
8010491f:	90                   	nop

80104920 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104920:	55                   	push   %ebp
80104921:	89 e5                	mov    %esp,%ebp
80104923:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104926:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104929:	50                   	push   %eax
8010492a:	ff 75 08             	push   0x8(%ebp)
8010492d:	e8 3e ff ff ff       	call   80104870 <argint>
80104932:	83 c4 10             	add    $0x10,%esp
80104935:	85 c0                	test   %eax,%eax
80104937:	78 17                	js     80104950 <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
80104939:	83 ec 08             	sub    $0x8,%esp
8010493c:	ff 75 0c             	push   0xc(%ebp)
8010493f:	ff 75 f4             	push   -0xc(%ebp)
80104942:	e8 d9 fe ff ff       	call   80104820 <fetchstr>
80104947:	83 c4 10             	add    $0x10,%esp
}
8010494a:	c9                   	leave
8010494b:	c3                   	ret
8010494c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104950:	c9                   	leave
    return -1;
80104951:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104956:	c3                   	ret
80104957:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010495e:	00 
8010495f:	90                   	nop

80104960 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80104960:	55                   	push   %ebp
80104961:	89 e5                	mov    %esp,%ebp
80104963:	53                   	push   %ebx
80104964:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104967:	e8 b4 ef ff ff       	call   80103920 <myproc>
8010496c:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010496e:	8b 40 18             	mov    0x18(%eax),%eax
80104971:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104974:	8d 50 ff             	lea    -0x1(%eax),%edx
80104977:	83 fa 14             	cmp    $0x14,%edx
8010497a:	77 24                	ja     801049a0 <syscall+0x40>
8010497c:	8b 14 85 60 78 10 80 	mov    -0x7fef87a0(,%eax,4),%edx
80104983:	85 d2                	test   %edx,%edx
80104985:	74 19                	je     801049a0 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80104987:	ff d2                	call   *%edx
80104989:	89 c2                	mov    %eax,%edx
8010498b:	8b 43 18             	mov    0x18(%ebx),%eax
8010498e:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104991:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104994:	c9                   	leave
80104995:	c3                   	ret
80104996:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010499d:	00 
8010499e:	66 90                	xchg   %ax,%ax
    cprintf("%d %s: unknown sys call %d\n",
801049a0:	50                   	push   %eax
            curproc->pid, curproc->name, num);
801049a1:	8d 43 6c             	lea    0x6c(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
801049a4:	50                   	push   %eax
801049a5:	ff 73 10             	push   0x10(%ebx)
801049a8:	68 d1 72 10 80       	push   $0x801072d1
801049ad:	e8 fe bc ff ff       	call   801006b0 <cprintf>
    curproc->tf->eax = -1;
801049b2:	8b 43 18             	mov    0x18(%ebx),%eax
801049b5:	83 c4 10             	add    $0x10,%esp
801049b8:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
801049bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049c2:	c9                   	leave
801049c3:	c3                   	ret
801049c4:	66 90                	xchg   %ax,%ax
801049c6:	66 90                	xchg   %ax,%ax
801049c8:	66 90                	xchg   %ax,%ax
801049ca:	66 90                	xchg   %ax,%ax
801049cc:	66 90                	xchg   %ax,%ax
801049ce:	66 90                	xchg   %ax,%ax

801049d0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801049d0:	55                   	push   %ebp
801049d1:	89 e5                	mov    %esp,%ebp
801049d3:	57                   	push   %edi
801049d4:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801049d5:	8d 7d da             	lea    -0x26(%ebp),%edi
{
801049d8:	53                   	push   %ebx
801049d9:	83 ec 34             	sub    $0x34,%esp
801049dc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801049df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
801049e2:	57                   	push   %edi
801049e3:	50                   	push   %eax
{
801049e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801049e7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
801049ea:	e8 b1 d6 ff ff       	call   801020a0 <nameiparent>
801049ef:	83 c4 10             	add    $0x10,%esp
801049f2:	85 c0                	test   %eax,%eax
801049f4:	0f 84 46 01 00 00    	je     80104b40 <create+0x170>
    return 0;
  ilock(dp);
801049fa:	83 ec 0c             	sub    $0xc,%esp
801049fd:	89 c3                	mov    %eax,%ebx
801049ff:	50                   	push   %eax
80104a00:	e8 9b cd ff ff       	call   801017a0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
80104a05:	83 c4 0c             	add    $0xc,%esp
80104a08:	6a 00                	push   $0x0
80104a0a:	57                   	push   %edi
80104a0b:	53                   	push   %ebx
80104a0c:	e8 df d2 ff ff       	call   80101cf0 <dirlookup>
80104a11:	83 c4 10             	add    $0x10,%esp
80104a14:	89 c6                	mov    %eax,%esi
80104a16:	85 c0                	test   %eax,%eax
80104a18:	74 56                	je     80104a70 <create+0xa0>
    iunlockput(dp);
80104a1a:	83 ec 0c             	sub    $0xc,%esp
80104a1d:	53                   	push   %ebx
80104a1e:	e8 0d d0 ff ff       	call   80101a30 <iunlockput>
    ilock(ip);
80104a23:	89 34 24             	mov    %esi,(%esp)
80104a26:	e8 75 cd ff ff       	call   801017a0 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104a2b:	83 c4 10             	add    $0x10,%esp
80104a2e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80104a33:	75 1b                	jne    80104a50 <create+0x80>
80104a35:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
80104a3a:	75 14                	jne    80104a50 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a3f:	89 f0                	mov    %esi,%eax
80104a41:	5b                   	pop    %ebx
80104a42:	5e                   	pop    %esi
80104a43:	5f                   	pop    %edi
80104a44:	5d                   	pop    %ebp
80104a45:	c3                   	ret
80104a46:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104a4d:	00 
80104a4e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80104a50:	83 ec 0c             	sub    $0xc,%esp
80104a53:	56                   	push   %esi
    return 0;
80104a54:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80104a56:	e8 d5 cf ff ff       	call   80101a30 <iunlockput>
    return 0;
80104a5b:	83 c4 10             	add    $0x10,%esp
}
80104a5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a61:	89 f0                	mov    %esi,%eax
80104a63:	5b                   	pop    %ebx
80104a64:	5e                   	pop    %esi
80104a65:	5f                   	pop    %edi
80104a66:	5d                   	pop    %ebp
80104a67:	c3                   	ret
80104a68:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104a6f:	00 
  if((ip = ialloc(dp->dev, type)) == 0)
80104a70:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80104a74:	83 ec 08             	sub    $0x8,%esp
80104a77:	50                   	push   %eax
80104a78:	ff 33                	push   (%ebx)
80104a7a:	e8 b1 cb ff ff       	call   80101630 <ialloc>
80104a7f:	83 c4 10             	add    $0x10,%esp
80104a82:	89 c6                	mov    %eax,%esi
80104a84:	85 c0                	test   %eax,%eax
80104a86:	0f 84 cd 00 00 00    	je     80104b59 <create+0x189>
  ilock(ip);
80104a8c:	83 ec 0c             	sub    $0xc,%esp
80104a8f:	50                   	push   %eax
80104a90:	e8 0b cd ff ff       	call   801017a0 <ilock>
  ip->major = major;
80104a95:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104a99:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
80104a9d:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
80104aa1:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80104aa5:	b8 01 00 00 00       	mov    $0x1,%eax
80104aaa:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
80104aae:	89 34 24             	mov    %esi,(%esp)
80104ab1:	e8 3a cc ff ff       	call   801016f0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104ab6:	83 c4 10             	add    $0x10,%esp
80104ab9:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104abe:	74 30                	je     80104af0 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80104ac0:	83 ec 04             	sub    $0x4,%esp
80104ac3:	ff 76 04             	push   0x4(%esi)
80104ac6:	57                   	push   %edi
80104ac7:	53                   	push   %ebx
80104ac8:	e8 f3 d4 ff ff       	call   80101fc0 <dirlink>
80104acd:	83 c4 10             	add    $0x10,%esp
80104ad0:	85 c0                	test   %eax,%eax
80104ad2:	78 78                	js     80104b4c <create+0x17c>
  iunlockput(dp);
80104ad4:	83 ec 0c             	sub    $0xc,%esp
80104ad7:	53                   	push   %ebx
80104ad8:	e8 53 cf ff ff       	call   80101a30 <iunlockput>
  return ip;
80104add:	83 c4 10             	add    $0x10,%esp
}
80104ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ae3:	89 f0                	mov    %esi,%eax
80104ae5:	5b                   	pop    %ebx
80104ae6:	5e                   	pop    %esi
80104ae7:	5f                   	pop    %edi
80104ae8:	5d                   	pop    %ebp
80104ae9:	c3                   	ret
80104aea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
80104af0:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
80104af3:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
80104af8:	53                   	push   %ebx
80104af9:	e8 f2 cb ff ff       	call   801016f0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104afe:	83 c4 0c             	add    $0xc,%esp
80104b01:	ff 76 04             	push   0x4(%esi)
80104b04:	68 09 73 10 80       	push   $0x80107309
80104b09:	56                   	push   %esi
80104b0a:	e8 b1 d4 ff ff       	call   80101fc0 <dirlink>
80104b0f:	83 c4 10             	add    $0x10,%esp
80104b12:	85 c0                	test   %eax,%eax
80104b14:	78 18                	js     80104b2e <create+0x15e>
80104b16:	83 ec 04             	sub    $0x4,%esp
80104b19:	ff 73 04             	push   0x4(%ebx)
80104b1c:	68 08 73 10 80       	push   $0x80107308
80104b21:	56                   	push   %esi
80104b22:	e8 99 d4 ff ff       	call   80101fc0 <dirlink>
80104b27:	83 c4 10             	add    $0x10,%esp
80104b2a:	85 c0                	test   %eax,%eax
80104b2c:	79 92                	jns    80104ac0 <create+0xf0>
      panic("create dots");
80104b2e:	83 ec 0c             	sub    $0xc,%esp
80104b31:	68 fc 72 10 80       	push   $0x801072fc
80104b36:	e8 45 b8 ff ff       	call   80100380 <panic>
80104b3b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
}
80104b40:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80104b43:	31 f6                	xor    %esi,%esi
}
80104b45:	5b                   	pop    %ebx
80104b46:	89 f0                	mov    %esi,%eax
80104b48:	5e                   	pop    %esi
80104b49:	5f                   	pop    %edi
80104b4a:	5d                   	pop    %ebp
80104b4b:	c3                   	ret
    panic("create: dirlink");
80104b4c:	83 ec 0c             	sub    $0xc,%esp
80104b4f:	68 0b 73 10 80       	push   $0x8010730b
80104b54:	e8 27 b8 ff ff       	call   80100380 <panic>
    panic("create: ialloc");
80104b59:	83 ec 0c             	sub    $0xc,%esp
80104b5c:	68 ed 72 10 80       	push   $0x801072ed
80104b61:	e8 1a b8 ff ff       	call   80100380 <panic>
80104b66:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104b6d:	00 
80104b6e:	66 90                	xchg   %ax,%ax

80104b70 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
80104b70:	55                   	push   %ebp
80104b71:	89 e5                	mov    %esp,%ebp
80104b73:	56                   	push   %esi
80104b74:	89 d6                	mov    %edx,%esi
80104b76:	53                   	push   %ebx
80104b77:	89 c3                	mov    %eax,%ebx
  if(argint(n, &fd) < 0)
80104b79:	8d 45 f4             	lea    -0xc(%ebp),%eax
argfd(int n, int *pfd, struct file **pf)
80104b7c:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
80104b7f:	50                   	push   %eax
80104b80:	6a 00                	push   $0x0
80104b82:	e8 e9 fc ff ff       	call   80104870 <argint>
80104b87:	83 c4 10             	add    $0x10,%esp
80104b8a:	85 c0                	test   %eax,%eax
80104b8c:	78 2a                	js     80104bb8 <argfd.constprop.0+0x48>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104b8e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104b92:	77 24                	ja     80104bb8 <argfd.constprop.0+0x48>
80104b94:	e8 87 ed ff ff       	call   80103920 <myproc>
80104b99:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b9c:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104ba0:	85 c0                	test   %eax,%eax
80104ba2:	74 14                	je     80104bb8 <argfd.constprop.0+0x48>
  if(pfd)
80104ba4:	85 db                	test   %ebx,%ebx
80104ba6:	74 02                	je     80104baa <argfd.constprop.0+0x3a>
    *pfd = fd;
80104ba8:	89 13                	mov    %edx,(%ebx)
    *pf = f;
80104baa:	89 06                	mov    %eax,(%esi)
  return 0;
80104bac:	31 c0                	xor    %eax,%eax
}
80104bae:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104bb1:	5b                   	pop    %ebx
80104bb2:	5e                   	pop    %esi
80104bb3:	5d                   	pop    %ebp
80104bb4:	c3                   	ret
80104bb5:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104bb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bbd:	eb ef                	jmp    80104bae <argfd.constprop.0+0x3e>
80104bbf:	90                   	nop

80104bc0 <sys_dup>:
{
80104bc0:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0)
80104bc1:	31 c0                	xor    %eax,%eax
{
80104bc3:	89 e5                	mov    %esp,%ebp
80104bc5:	56                   	push   %esi
80104bc6:	53                   	push   %ebx
  if(argfd(0, 0, &f) < 0)
80104bc7:	8d 55 f4             	lea    -0xc(%ebp),%edx
{
80104bca:	83 ec 10             	sub    $0x10,%esp
  if(argfd(0, 0, &f) < 0)
80104bcd:	e8 9e ff ff ff       	call   80104b70 <argfd.constprop.0>
80104bd2:	85 c0                	test   %eax,%eax
80104bd4:	78 1a                	js     80104bf0 <sys_dup+0x30>
  if((fd=fdalloc(f)) < 0)
80104bd6:	8b 75 f4             	mov    -0xc(%ebp),%esi
  for(fd = 0; fd < NOFILE; fd++){
80104bd9:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80104bdb:	e8 40 ed ff ff       	call   80103920 <myproc>
    if(curproc->ofile[fd] == 0){
80104be0:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80104be4:	85 d2                	test   %edx,%edx
80104be6:	74 18                	je     80104c00 <sys_dup+0x40>
  for(fd = 0; fd < NOFILE; fd++){
80104be8:	83 c3 01             	add    $0x1,%ebx
80104beb:	83 fb 10             	cmp    $0x10,%ebx
80104bee:	75 f0                	jne    80104be0 <sys_dup+0x20>
}
80104bf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80104bf3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80104bf8:	89 d8                	mov    %ebx,%eax
80104bfa:	5b                   	pop    %ebx
80104bfb:	5e                   	pop    %esi
80104bfc:	5d                   	pop    %ebp
80104bfd:	c3                   	ret
80104bfe:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80104c00:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)
  filedup(f);
80104c04:	83 ec 0c             	sub    $0xc,%esp
80104c07:	ff 75 f4             	push   -0xc(%ebp)
80104c0a:	e8 b1 c2 ff ff       	call   80100ec0 <filedup>
  return fd;
80104c0f:	83 c4 10             	add    $0x10,%esp
}
80104c12:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104c15:	89 d8                	mov    %ebx,%eax
80104c17:	5b                   	pop    %ebx
80104c18:	5e                   	pop    %esi
80104c19:	5d                   	pop    %ebp
80104c1a:	c3                   	ret
80104c1b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

80104c20 <sys_read>:
{
80104c20:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104c21:	31 c0                	xor    %eax,%eax
{
80104c23:	89 e5                	mov    %esp,%ebp
80104c25:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104c28:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104c2b:	e8 40 ff ff ff       	call   80104b70 <argfd.constprop.0>
80104c30:	85 c0                	test   %eax,%eax
80104c32:	78 4c                	js     80104c80 <sys_read+0x60>
80104c34:	83 ec 08             	sub    $0x8,%esp
80104c37:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c3a:	50                   	push   %eax
80104c3b:	6a 02                	push   $0x2
80104c3d:	e8 2e fc ff ff       	call   80104870 <argint>
80104c42:	83 c4 10             	add    $0x10,%esp
80104c45:	85 c0                	test   %eax,%eax
80104c47:	78 37                	js     80104c80 <sys_read+0x60>
80104c49:	83 ec 04             	sub    $0x4,%esp
80104c4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c4f:	ff 75 f0             	push   -0x10(%ebp)
80104c52:	50                   	push   %eax
80104c53:	6a 01                	push   $0x1
80104c55:	e8 66 fc ff ff       	call   801048c0 <argptr>
80104c5a:	83 c4 10             	add    $0x10,%esp
80104c5d:	85 c0                	test   %eax,%eax
80104c5f:	78 1f                	js     80104c80 <sys_read+0x60>
  return fileread(f, p, n);
80104c61:	83 ec 04             	sub    $0x4,%esp
80104c64:	ff 75 f0             	push   -0x10(%ebp)
80104c67:	ff 75 f4             	push   -0xc(%ebp)
80104c6a:	ff 75 ec             	push   -0x14(%ebp)
80104c6d:	e8 ce c3 ff ff       	call   80101040 <fileread>
80104c72:	83 c4 10             	add    $0x10,%esp
}
80104c75:	c9                   	leave
80104c76:	c3                   	ret
80104c77:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104c7e:	00 
80104c7f:	90                   	nop
80104c80:	c9                   	leave
    return -1;
80104c81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c86:	c3                   	ret
80104c87:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104c8e:	00 
80104c8f:	90                   	nop

80104c90 <sys_write>:
{
80104c90:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104c91:	31 c0                	xor    %eax,%eax
{
80104c93:	89 e5                	mov    %esp,%ebp
80104c95:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104c98:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104c9b:	e8 d0 fe ff ff       	call   80104b70 <argfd.constprop.0>
80104ca0:	85 c0                	test   %eax,%eax
80104ca2:	78 4c                	js     80104cf0 <sys_write+0x60>
80104ca4:	83 ec 08             	sub    $0x8,%esp
80104ca7:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104caa:	50                   	push   %eax
80104cab:	6a 02                	push   $0x2
80104cad:	e8 be fb ff ff       	call   80104870 <argint>
80104cb2:	83 c4 10             	add    $0x10,%esp
80104cb5:	85 c0                	test   %eax,%eax
80104cb7:	78 37                	js     80104cf0 <sys_write+0x60>
80104cb9:	83 ec 04             	sub    $0x4,%esp
80104cbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cbf:	ff 75 f0             	push   -0x10(%ebp)
80104cc2:	50                   	push   %eax
80104cc3:	6a 01                	push   $0x1
80104cc5:	e8 f6 fb ff ff       	call   801048c0 <argptr>
80104cca:	83 c4 10             	add    $0x10,%esp
80104ccd:	85 c0                	test   %eax,%eax
80104ccf:	78 1f                	js     80104cf0 <sys_write+0x60>
  return filewrite(f, p, n);
80104cd1:	83 ec 04             	sub    $0x4,%esp
80104cd4:	ff 75 f0             	push   -0x10(%ebp)
80104cd7:	ff 75 f4             	push   -0xc(%ebp)
80104cda:	ff 75 ec             	push   -0x14(%ebp)
80104cdd:	e8 ee c3 ff ff       	call   801010d0 <filewrite>
80104ce2:	83 c4 10             	add    $0x10,%esp
}
80104ce5:	c9                   	leave
80104ce6:	c3                   	ret
80104ce7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104cee:	00 
80104cef:	90                   	nop
80104cf0:	c9                   	leave
    return -1;
80104cf1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cf6:	c3                   	ret
80104cf7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104cfe:	00 
80104cff:	90                   	nop

80104d00 <sys_close>:
{
80104d00:	55                   	push   %ebp
80104d01:	89 e5                	mov    %esp,%ebp
80104d03:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104d06:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104d09:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d0c:	e8 5f fe ff ff       	call   80104b70 <argfd.constprop.0>
80104d11:	85 c0                	test   %eax,%eax
80104d13:	78 2b                	js     80104d40 <sys_close+0x40>
  myproc()->ofile[fd] = 0;
80104d15:	e8 06 ec ff ff       	call   80103920 <myproc>
80104d1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
80104d1d:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
80104d20:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104d27:	00 
  fileclose(f);
80104d28:	ff 75 f4             	push   -0xc(%ebp)
80104d2b:	e8 e0 c1 ff ff       	call   80100f10 <fileclose>
  return 0;
80104d30:	83 c4 10             	add    $0x10,%esp
80104d33:	31 c0                	xor    %eax,%eax
}
80104d35:	c9                   	leave
80104d36:	c3                   	ret
80104d37:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104d3e:	00 
80104d3f:	90                   	nop
80104d40:	c9                   	leave
    return -1;
80104d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d46:	c3                   	ret
80104d47:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104d4e:	00 
80104d4f:	90                   	nop

80104d50 <sys_fstat>:
{
80104d50:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104d51:	31 c0                	xor    %eax,%eax
{
80104d53:	89 e5                	mov    %esp,%ebp
80104d55:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104d58:	8d 55 f0             	lea    -0x10(%ebp),%edx
80104d5b:	e8 10 fe ff ff       	call   80104b70 <argfd.constprop.0>
80104d60:	85 c0                	test   %eax,%eax
80104d62:	78 2c                	js     80104d90 <sys_fstat+0x40>
80104d64:	83 ec 04             	sub    $0x4,%esp
80104d67:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d6a:	6a 14                	push   $0x14
80104d6c:	50                   	push   %eax
80104d6d:	6a 01                	push   $0x1
80104d6f:	e8 4c fb ff ff       	call   801048c0 <argptr>
80104d74:	83 c4 10             	add    $0x10,%esp
80104d77:	85 c0                	test   %eax,%eax
80104d79:	78 15                	js     80104d90 <sys_fstat+0x40>
  return filestat(f, st);
80104d7b:	83 ec 08             	sub    $0x8,%esp
80104d7e:	ff 75 f4             	push   -0xc(%ebp)
80104d81:	ff 75 f0             	push   -0x10(%ebp)
80104d84:	e8 67 c2 ff ff       	call   80100ff0 <filestat>
80104d89:	83 c4 10             	add    $0x10,%esp
}
80104d8c:	c9                   	leave
80104d8d:	c3                   	ret
80104d8e:	66 90                	xchg   %ax,%ax
80104d90:	c9                   	leave
    return -1;
80104d91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d96:	c3                   	ret
80104d97:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104d9e:	00 
80104d9f:	90                   	nop

80104da0 <sys_link>:
{
80104da0:	55                   	push   %ebp
80104da1:	89 e5                	mov    %esp,%ebp
80104da3:	57                   	push   %edi
80104da4:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104da5:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80104da8:	53                   	push   %ebx
80104da9:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104dac:	50                   	push   %eax
80104dad:	6a 00                	push   $0x0
80104daf:	e8 6c fb ff ff       	call   80104920 <argstr>
80104db4:	83 c4 10             	add    $0x10,%esp
80104db7:	85 c0                	test   %eax,%eax
80104db9:	0f 88 fb 00 00 00    	js     80104eba <sys_link+0x11a>
80104dbf:	83 ec 08             	sub    $0x8,%esp
80104dc2:	8d 45 d0             	lea    -0x30(%ebp),%eax
80104dc5:	50                   	push   %eax
80104dc6:	6a 01                	push   $0x1
80104dc8:	e8 53 fb ff ff       	call   80104920 <argstr>
80104dcd:	83 c4 10             	add    $0x10,%esp
80104dd0:	85 c0                	test   %eax,%eax
80104dd2:	0f 88 e2 00 00 00    	js     80104eba <sys_link+0x11a>
  begin_op();
80104dd8:	e8 63 df ff ff       	call   80102d40 <begin_op>
  if((ip = namei(old)) == 0){
80104ddd:	83 ec 0c             	sub    $0xc,%esp
80104de0:	ff 75 d4             	push   -0x2c(%ebp)
80104de3:	e8 98 d2 ff ff       	call   80102080 <namei>
80104de8:	83 c4 10             	add    $0x10,%esp
80104deb:	89 c3                	mov    %eax,%ebx
80104ded:	85 c0                	test   %eax,%eax
80104def:	0f 84 e4 00 00 00    	je     80104ed9 <sys_link+0x139>
  ilock(ip);
80104df5:	83 ec 0c             	sub    $0xc,%esp
80104df8:	50                   	push   %eax
80104df9:	e8 a2 c9 ff ff       	call   801017a0 <ilock>
  if(ip->type == T_DIR){
80104dfe:	83 c4 10             	add    $0x10,%esp
80104e01:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104e06:	0f 84 b5 00 00 00    	je     80104ec1 <sys_link+0x121>
  iupdate(ip);
80104e0c:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
80104e0f:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
80104e14:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
80104e17:	53                   	push   %ebx
80104e18:	e8 d3 c8 ff ff       	call   801016f0 <iupdate>
  iunlock(ip);
80104e1d:	89 1c 24             	mov    %ebx,(%esp)
80104e20:	e8 5b ca ff ff       	call   80101880 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104e25:	58                   	pop    %eax
80104e26:	5a                   	pop    %edx
80104e27:	57                   	push   %edi
80104e28:	ff 75 d0             	push   -0x30(%ebp)
80104e2b:	e8 70 d2 ff ff       	call   801020a0 <nameiparent>
80104e30:	83 c4 10             	add    $0x10,%esp
80104e33:	89 c6                	mov    %eax,%esi
80104e35:	85 c0                	test   %eax,%eax
80104e37:	74 5b                	je     80104e94 <sys_link+0xf4>
  ilock(dp);
80104e39:	83 ec 0c             	sub    $0xc,%esp
80104e3c:	50                   	push   %eax
80104e3d:	e8 5e c9 ff ff       	call   801017a0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104e42:	8b 03                	mov    (%ebx),%eax
80104e44:	83 c4 10             	add    $0x10,%esp
80104e47:	39 06                	cmp    %eax,(%esi)
80104e49:	75 3d                	jne    80104e88 <sys_link+0xe8>
80104e4b:	83 ec 04             	sub    $0x4,%esp
80104e4e:	ff 73 04             	push   0x4(%ebx)
80104e51:	57                   	push   %edi
80104e52:	56                   	push   %esi
80104e53:	e8 68 d1 ff ff       	call   80101fc0 <dirlink>
80104e58:	83 c4 10             	add    $0x10,%esp
80104e5b:	85 c0                	test   %eax,%eax
80104e5d:	78 29                	js     80104e88 <sys_link+0xe8>
  iunlockput(dp);
80104e5f:	83 ec 0c             	sub    $0xc,%esp
80104e62:	56                   	push   %esi
80104e63:	e8 c8 cb ff ff       	call   80101a30 <iunlockput>
  iput(ip);
80104e68:	89 1c 24             	mov    %ebx,(%esp)
80104e6b:	e8 60 ca ff ff       	call   801018d0 <iput>
  end_op();
80104e70:	e8 3b df ff ff       	call   80102db0 <end_op>
  return 0;
80104e75:	83 c4 10             	add    $0x10,%esp
80104e78:	31 c0                	xor    %eax,%eax
}
80104e7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e7d:	5b                   	pop    %ebx
80104e7e:	5e                   	pop    %esi
80104e7f:	5f                   	pop    %edi
80104e80:	5d                   	pop    %ebp
80104e81:	c3                   	ret
80104e82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80104e88:	83 ec 0c             	sub    $0xc,%esp
80104e8b:	56                   	push   %esi
80104e8c:	e8 9f cb ff ff       	call   80101a30 <iunlockput>
    goto bad;
80104e91:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104e94:	83 ec 0c             	sub    $0xc,%esp
80104e97:	53                   	push   %ebx
80104e98:	e8 03 c9 ff ff       	call   801017a0 <ilock>
  ip->nlink--;
80104e9d:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80104ea2:	89 1c 24             	mov    %ebx,(%esp)
80104ea5:	e8 46 c8 ff ff       	call   801016f0 <iupdate>
  iunlockput(ip);
80104eaa:	89 1c 24             	mov    %ebx,(%esp)
80104ead:	e8 7e cb ff ff       	call   80101a30 <iunlockput>
  end_op();
80104eb2:	e8 f9 de ff ff       	call   80102db0 <end_op>
  return -1;
80104eb7:	83 c4 10             	add    $0x10,%esp
80104eba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ebf:	eb b9                	jmp    80104e7a <sys_link+0xda>
    iunlockput(ip);
80104ec1:	83 ec 0c             	sub    $0xc,%esp
80104ec4:	53                   	push   %ebx
80104ec5:	e8 66 cb ff ff       	call   80101a30 <iunlockput>
    end_op();
80104eca:	e8 e1 de ff ff       	call   80102db0 <end_op>
    return -1;
80104ecf:	83 c4 10             	add    $0x10,%esp
80104ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ed7:	eb a1                	jmp    80104e7a <sys_link+0xda>
    end_op();
80104ed9:	e8 d2 de ff ff       	call   80102db0 <end_op>
    return -1;
80104ede:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee3:	eb 95                	jmp    80104e7a <sys_link+0xda>
80104ee5:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80104eec:	00 
80104eed:	8d 76 00             	lea    0x0(%esi),%esi

80104ef0 <sys_unlink>:
{
80104ef0:	55                   	push   %ebp
80104ef1:	89 e5                	mov    %esp,%ebp
80104ef3:	57                   	push   %edi
80104ef4:	56                   	push   %esi
  if(argstr(0, &path) < 0)
80104ef5:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
80104ef8:	53                   	push   %ebx
80104ef9:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
80104efc:	50                   	push   %eax
80104efd:	6a 00                	push   $0x0
80104eff:	e8 1c fa ff ff       	call   80104920 <argstr>
80104f04:	83 c4 10             	add    $0x10,%esp
80104f07:	85 c0                	test   %eax,%eax
80104f09:	0f 88 91 01 00 00    	js     801050a0 <sys_unlink+0x1b0>
  begin_op();
80104f0f:	e8 2c de ff ff       	call   80102d40 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104f14:	8d 5d ca             	lea    -0x36(%ebp),%ebx
80104f17:	83 ec 08             	sub    $0x8,%esp
80104f1a:	53                   	push   %ebx
80104f1b:	ff 75 c0             	push   -0x40(%ebp)
80104f1e:	e8 7d d1 ff ff       	call   801020a0 <nameiparent>
80104f23:	83 c4 10             	add    $0x10,%esp
80104f26:	89 c6                	mov    %eax,%esi
80104f28:	85 c0                	test   %eax,%eax
80104f2a:	0f 84 7a 01 00 00    	je     801050aa <sys_unlink+0x1ba>
  ilock(dp);
80104f30:	83 ec 0c             	sub    $0xc,%esp
80104f33:	50                   	push   %eax
80104f34:	e8 67 c8 ff ff       	call   801017a0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104f39:	58                   	pop    %eax
80104f3a:	5a                   	pop    %edx
80104f3b:	68 09 73 10 80       	push   $0x80107309
80104f40:	53                   	push   %ebx
80104f41:	e8 8a cd ff ff       	call   80101cd0 <namecmp>
80104f46:	83 c4 10             	add    $0x10,%esp
80104f49:	85 c0                	test   %eax,%eax
80104f4b:	0f 84 0f 01 00 00    	je     80105060 <sys_unlink+0x170>
80104f51:	83 ec 08             	sub    $0x8,%esp
80104f54:	68 08 73 10 80       	push   $0x80107308
80104f59:	53                   	push   %ebx
80104f5a:	e8 71 cd ff ff       	call   80101cd0 <namecmp>
80104f5f:	83 c4 10             	add    $0x10,%esp
80104f62:	85 c0                	test   %eax,%eax
80104f64:	0f 84 f6 00 00 00    	je     80105060 <sys_unlink+0x170>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104f6a:	83 ec 04             	sub    $0x4,%esp
80104f6d:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104f70:	50                   	push   %eax
80104f71:	53                   	push   %ebx
80104f72:	56                   	push   %esi
80104f73:	e8 78 cd ff ff       	call   80101cf0 <dirlookup>
80104f78:	83 c4 10             	add    $0x10,%esp
80104f7b:	89 c3                	mov    %eax,%ebx
80104f7d:	85 c0                	test   %eax,%eax
80104f7f:	0f 84 db 00 00 00    	je     80105060 <sys_unlink+0x170>
  ilock(ip);
80104f85:	83 ec 0c             	sub    $0xc,%esp
80104f88:	50                   	push   %eax
80104f89:	e8 12 c8 ff ff       	call   801017a0 <ilock>
  if(ip->nlink < 1)
80104f8e:	83 c4 10             	add    $0x10,%esp
80104f91:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104f96:	0f 8e 37 01 00 00    	jle    801050d3 <sys_unlink+0x1e3>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104f9c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104fa1:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104fa4:	74 6a                	je     80105010 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
80104fa6:	83 ec 04             	sub    $0x4,%esp
80104fa9:	6a 10                	push   $0x10
80104fab:	6a 00                	push   $0x0
80104fad:	57                   	push   %edi
80104fae:	e8 fd f5 ff ff       	call   801045b0 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104fb3:	6a 10                	push   $0x10
80104fb5:	ff 75 c4             	push   -0x3c(%ebp)
80104fb8:	57                   	push   %edi
80104fb9:	56                   	push   %esi
80104fba:	e8 f1 cb ff ff       	call   80101bb0 <writei>
80104fbf:	83 c4 20             	add    $0x20,%esp
80104fc2:	83 f8 10             	cmp    $0x10,%eax
80104fc5:	0f 85 fb 00 00 00    	jne    801050c6 <sys_unlink+0x1d6>
  if(ip->type == T_DIR){
80104fcb:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104fd0:	0f 84 aa 00 00 00    	je     80105080 <sys_unlink+0x190>
  iunlockput(dp);
80104fd6:	83 ec 0c             	sub    $0xc,%esp
80104fd9:	56                   	push   %esi
80104fda:	e8 51 ca ff ff       	call   80101a30 <iunlockput>
  ip->nlink--;
80104fdf:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80104fe4:	89 1c 24             	mov    %ebx,(%esp)
80104fe7:	e8 04 c7 ff ff       	call   801016f0 <iupdate>
  iunlockput(ip);
80104fec:	89 1c 24             	mov    %ebx,(%esp)
80104fef:	e8 3c ca ff ff       	call   80101a30 <iunlockput>
  end_op();
80104ff4:	e8 b7 dd ff ff       	call   80102db0 <end_op>
  return 0;
80104ff9:	83 c4 10             	add    $0x10,%esp
80104ffc:	31 c0                	xor    %eax,%eax
}
80104ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105001:	5b                   	pop    %ebx
80105002:	5e                   	pop    %esi
80105003:	5f                   	pop    %edi
80105004:	5d                   	pop    %ebp
80105005:	c3                   	ret
80105006:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010500d:	00 
8010500e:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105010:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80105014:	76 90                	jbe    80104fa6 <sys_unlink+0xb6>
80105016:	ba 20 00 00 00       	mov    $0x20,%edx
8010501b:	eb 0f                	jmp    8010502c <sys_unlink+0x13c>
8010501d:	8d 76 00             	lea    0x0(%esi),%esi
80105020:	83 c2 10             	add    $0x10,%edx
80105023:	39 53 58             	cmp    %edx,0x58(%ebx)
80105026:	0f 86 7a ff ff ff    	jbe    80104fa6 <sys_unlink+0xb6>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010502c:	6a 10                	push   $0x10
8010502e:	52                   	push   %edx
8010502f:	57                   	push   %edi
80105030:	53                   	push   %ebx
80105031:	89 55 b4             	mov    %edx,-0x4c(%ebp)
80105034:	e8 77 ca ff ff       	call   80101ab0 <readi>
80105039:	83 c4 10             	add    $0x10,%esp
8010503c:	8b 55 b4             	mov    -0x4c(%ebp),%edx
8010503f:	83 f8 10             	cmp    $0x10,%eax
80105042:	75 75                	jne    801050b9 <sys_unlink+0x1c9>
    if(de.inum != 0)
80105044:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80105049:	74 d5                	je     80105020 <sys_unlink+0x130>
    iunlockput(ip);
8010504b:	83 ec 0c             	sub    $0xc,%esp
8010504e:	53                   	push   %ebx
8010504f:	e8 dc c9 ff ff       	call   80101a30 <iunlockput>
    goto bad;
80105054:	83 c4 10             	add    $0x10,%esp
80105057:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010505e:	00 
8010505f:	90                   	nop
  iunlockput(dp);
80105060:	83 ec 0c             	sub    $0xc,%esp
80105063:	56                   	push   %esi
80105064:	e8 c7 c9 ff ff       	call   80101a30 <iunlockput>
  end_op();
80105069:	e8 42 dd ff ff       	call   80102db0 <end_op>
  return -1;
8010506e:	83 c4 10             	add    $0x10,%esp
80105071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105076:	eb 86                	jmp    80104ffe <sys_unlink+0x10e>
80105078:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010507f:	00 
    iupdate(dp);
80105080:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105083:	66 83 6e 56 01       	subw   $0x1,0x56(%esi)
    iupdate(dp);
80105088:	56                   	push   %esi
80105089:	e8 62 c6 ff ff       	call   801016f0 <iupdate>
8010508e:	83 c4 10             	add    $0x10,%esp
80105091:	e9 40 ff ff ff       	jmp    80104fd6 <sys_unlink+0xe6>
80105096:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010509d:	00 
8010509e:	66 90                	xchg   %ax,%ax
    return -1;
801050a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050a5:	e9 54 ff ff ff       	jmp    80104ffe <sys_unlink+0x10e>
    end_op();
801050aa:	e8 01 dd ff ff       	call   80102db0 <end_op>
    return -1;
801050af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050b4:	e9 45 ff ff ff       	jmp    80104ffe <sys_unlink+0x10e>
      panic("isdirempty: readi");
801050b9:	83 ec 0c             	sub    $0xc,%esp
801050bc:	68 2d 73 10 80       	push   $0x8010732d
801050c1:	e8 ba b2 ff ff       	call   80100380 <panic>
    panic("unlink: writei");
801050c6:	83 ec 0c             	sub    $0xc,%esp
801050c9:	68 3f 73 10 80       	push   $0x8010733f
801050ce:	e8 ad b2 ff ff       	call   80100380 <panic>
    panic("unlink: nlink < 1");
801050d3:	83 ec 0c             	sub    $0xc,%esp
801050d6:	68 1b 73 10 80       	push   $0x8010731b
801050db:	e8 a0 b2 ff ff       	call   80100380 <panic>

801050e0 <sys_open>:

int
sys_open(void)
{
801050e0:	55                   	push   %ebp
801050e1:	89 e5                	mov    %esp,%ebp
801050e3:	57                   	push   %edi
801050e4:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801050e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
801050e8:	53                   	push   %ebx
801050e9:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801050ec:	50                   	push   %eax
801050ed:	6a 00                	push   $0x0
801050ef:	e8 2c f8 ff ff       	call   80104920 <argstr>
801050f4:	83 c4 10             	add    $0x10,%esp
801050f7:	85 c0                	test   %eax,%eax
801050f9:	0f 88 8e 00 00 00    	js     8010518d <sys_open+0xad>
801050ff:	83 ec 08             	sub    $0x8,%esp
80105102:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105105:	50                   	push   %eax
80105106:	6a 01                	push   $0x1
80105108:	e8 63 f7 ff ff       	call   80104870 <argint>
8010510d:	83 c4 10             	add    $0x10,%esp
80105110:	85 c0                	test   %eax,%eax
80105112:	78 79                	js     8010518d <sys_open+0xad>
    return -1;

  begin_op();
80105114:	e8 27 dc ff ff       	call   80102d40 <begin_op>

  if(omode & O_CREATE){
80105119:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
8010511d:	75 79                	jne    80105198 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
8010511f:	83 ec 0c             	sub    $0xc,%esp
80105122:	ff 75 e0             	push   -0x20(%ebp)
80105125:	e8 56 cf ff ff       	call   80102080 <namei>
8010512a:	83 c4 10             	add    $0x10,%esp
8010512d:	89 c6                	mov    %eax,%esi
8010512f:	85 c0                	test   %eax,%eax
80105131:	0f 84 7e 00 00 00    	je     801051b5 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
80105137:	83 ec 0c             	sub    $0xc,%esp
8010513a:	50                   	push   %eax
8010513b:	e8 60 c6 ff ff       	call   801017a0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105140:	83 c4 10             	add    $0x10,%esp
80105143:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80105148:	0f 84 c2 00 00 00    	je     80105210 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010514e:	e8 fd bc ff ff       	call   80100e50 <filealloc>
80105153:	89 c7                	mov    %eax,%edi
80105155:	85 c0                	test   %eax,%eax
80105157:	74 23                	je     8010517c <sys_open+0x9c>
  struct proc *curproc = myproc();
80105159:	e8 c2 e7 ff ff       	call   80103920 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010515e:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80105160:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80105164:	85 d2                	test   %edx,%edx
80105166:	74 60                	je     801051c8 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
80105168:	83 c3 01             	add    $0x1,%ebx
8010516b:	83 fb 10             	cmp    $0x10,%ebx
8010516e:	75 f0                	jne    80105160 <sys_open+0x80>
    if(f)
      fileclose(f);
80105170:	83 ec 0c             	sub    $0xc,%esp
80105173:	57                   	push   %edi
80105174:	e8 97 bd ff ff       	call   80100f10 <fileclose>
80105179:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010517c:	83 ec 0c             	sub    $0xc,%esp
8010517f:	56                   	push   %esi
80105180:	e8 ab c8 ff ff       	call   80101a30 <iunlockput>
    end_op();
80105185:	e8 26 dc ff ff       	call   80102db0 <end_op>
    return -1;
8010518a:	83 c4 10             	add    $0x10,%esp
8010518d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105192:	eb 6d                	jmp    80105201 <sys_open+0x121>
80105194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80105198:	83 ec 0c             	sub    $0xc,%esp
8010519b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010519e:	31 c9                	xor    %ecx,%ecx
801051a0:	ba 02 00 00 00       	mov    $0x2,%edx
801051a5:	6a 00                	push   $0x0
801051a7:	e8 24 f8 ff ff       	call   801049d0 <create>
    if(ip == 0){
801051ac:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
801051af:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801051b1:	85 c0                	test   %eax,%eax
801051b3:	75 99                	jne    8010514e <sys_open+0x6e>
      end_op();
801051b5:	e8 f6 db ff ff       	call   80102db0 <end_op>
      return -1;
801051ba:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801051bf:	eb 40                	jmp    80105201 <sys_open+0x121>
801051c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
801051c8:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
801051cb:	89 7c 98 28          	mov    %edi,0x28(%eax,%ebx,4)
  iunlock(ip);
801051cf:	56                   	push   %esi
801051d0:	e8 ab c6 ff ff       	call   80101880 <iunlock>
  end_op();
801051d5:	e8 d6 db ff ff       	call   80102db0 <end_op>

  f->type = FD_INODE;
801051da:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
801051e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801051e3:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
801051e6:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
801051e9:	89 d0                	mov    %edx,%eax
  f->off = 0;
801051eb:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
801051f2:	f7 d0                	not    %eax
801051f4:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801051f7:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
801051fa:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801051fd:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
80105201:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105204:	89 d8                	mov    %ebx,%eax
80105206:	5b                   	pop    %ebx
80105207:	5e                   	pop    %esi
80105208:	5f                   	pop    %edi
80105209:	5d                   	pop    %ebp
8010520a:	c3                   	ret
8010520b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
    if(ip->type == T_DIR && omode != O_RDONLY){
80105210:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80105213:	85 c9                	test   %ecx,%ecx
80105215:	0f 84 33 ff ff ff    	je     8010514e <sys_open+0x6e>
8010521b:	e9 5c ff ff ff       	jmp    8010517c <sys_open+0x9c>

80105220 <sys_mkdir>:

int
sys_mkdir(void)
{
80105220:	55                   	push   %ebp
80105221:	89 e5                	mov    %esp,%ebp
80105223:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105226:	e8 15 db ff ff       	call   80102d40 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010522b:	83 ec 08             	sub    $0x8,%esp
8010522e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105231:	50                   	push   %eax
80105232:	6a 00                	push   $0x0
80105234:	e8 e7 f6 ff ff       	call   80104920 <argstr>
80105239:	83 c4 10             	add    $0x10,%esp
8010523c:	85 c0                	test   %eax,%eax
8010523e:	78 30                	js     80105270 <sys_mkdir+0x50>
80105240:	83 ec 0c             	sub    $0xc,%esp
80105243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105246:	31 c9                	xor    %ecx,%ecx
80105248:	ba 01 00 00 00       	mov    $0x1,%edx
8010524d:	6a 00                	push   $0x0
8010524f:	e8 7c f7 ff ff       	call   801049d0 <create>
80105254:	83 c4 10             	add    $0x10,%esp
80105257:	85 c0                	test   %eax,%eax
80105259:	74 15                	je     80105270 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010525b:	83 ec 0c             	sub    $0xc,%esp
8010525e:	50                   	push   %eax
8010525f:	e8 cc c7 ff ff       	call   80101a30 <iunlockput>
  end_op();
80105264:	e8 47 db ff ff       	call   80102db0 <end_op>
  return 0;
80105269:	83 c4 10             	add    $0x10,%esp
8010526c:	31 c0                	xor    %eax,%eax
}
8010526e:	c9                   	leave
8010526f:	c3                   	ret
    end_op();
80105270:	e8 3b db ff ff       	call   80102db0 <end_op>
    return -1;
80105275:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010527a:	c9                   	leave
8010527b:	c3                   	ret
8010527c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105280 <sys_mknod>:

int
sys_mknod(void)
{
80105280:	55                   	push   %ebp
80105281:	89 e5                	mov    %esp,%ebp
80105283:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105286:	e8 b5 da ff ff       	call   80102d40 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010528b:	83 ec 08             	sub    $0x8,%esp
8010528e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105291:	50                   	push   %eax
80105292:	6a 00                	push   $0x0
80105294:	e8 87 f6 ff ff       	call   80104920 <argstr>
80105299:	83 c4 10             	add    $0x10,%esp
8010529c:	85 c0                	test   %eax,%eax
8010529e:	78 60                	js     80105300 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801052a0:	83 ec 08             	sub    $0x8,%esp
801052a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052a6:	50                   	push   %eax
801052a7:	6a 01                	push   $0x1
801052a9:	e8 c2 f5 ff ff       	call   80104870 <argint>
  if((argstr(0, &path)) < 0 ||
801052ae:	83 c4 10             	add    $0x10,%esp
801052b1:	85 c0                	test   %eax,%eax
801052b3:	78 4b                	js     80105300 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
801052b5:	83 ec 08             	sub    $0x8,%esp
801052b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052bb:	50                   	push   %eax
801052bc:	6a 02                	push   $0x2
801052be:	e8 ad f5 ff ff       	call   80104870 <argint>
     argint(1, &major) < 0 ||
801052c3:	83 c4 10             	add    $0x10,%esp
801052c6:	85 c0                	test   %eax,%eax
801052c8:	78 36                	js     80105300 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
801052ca:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
801052ce:	83 ec 0c             	sub    $0xc,%esp
801052d1:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
801052d5:	ba 03 00 00 00       	mov    $0x3,%edx
801052da:	50                   	push   %eax
801052db:	8b 45 ec             	mov    -0x14(%ebp),%eax
801052de:	e8 ed f6 ff ff       	call   801049d0 <create>
     argint(2, &minor) < 0 ||
801052e3:	83 c4 10             	add    $0x10,%esp
801052e6:	85 c0                	test   %eax,%eax
801052e8:	74 16                	je     80105300 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
801052ea:	83 ec 0c             	sub    $0xc,%esp
801052ed:	50                   	push   %eax
801052ee:	e8 3d c7 ff ff       	call   80101a30 <iunlockput>
  end_op();
801052f3:	e8 b8 da ff ff       	call   80102db0 <end_op>
  return 0;
801052f8:	83 c4 10             	add    $0x10,%esp
801052fb:	31 c0                	xor    %eax,%eax
}
801052fd:	c9                   	leave
801052fe:	c3                   	ret
801052ff:	90                   	nop
    end_op();
80105300:	e8 ab da ff ff       	call   80102db0 <end_op>
    return -1;
80105305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010530a:	c9                   	leave
8010530b:	c3                   	ret
8010530c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105310 <sys_chdir>:

int
sys_chdir(void)
{
80105310:	55                   	push   %ebp
80105311:	89 e5                	mov    %esp,%ebp
80105313:	56                   	push   %esi
80105314:	53                   	push   %ebx
80105315:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105318:	e8 03 e6 ff ff       	call   80103920 <myproc>
8010531d:	89 c6                	mov    %eax,%esi
  
  begin_op();
8010531f:	e8 1c da ff ff       	call   80102d40 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105324:	83 ec 08             	sub    $0x8,%esp
80105327:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010532a:	50                   	push   %eax
8010532b:	6a 00                	push   $0x0
8010532d:	e8 ee f5 ff ff       	call   80104920 <argstr>
80105332:	83 c4 10             	add    $0x10,%esp
80105335:	85 c0                	test   %eax,%eax
80105337:	78 77                	js     801053b0 <sys_chdir+0xa0>
80105339:	83 ec 0c             	sub    $0xc,%esp
8010533c:	ff 75 f4             	push   -0xc(%ebp)
8010533f:	e8 3c cd ff ff       	call   80102080 <namei>
80105344:	83 c4 10             	add    $0x10,%esp
80105347:	89 c3                	mov    %eax,%ebx
80105349:	85 c0                	test   %eax,%eax
8010534b:	74 63                	je     801053b0 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
8010534d:	83 ec 0c             	sub    $0xc,%esp
80105350:	50                   	push   %eax
80105351:	e8 4a c4 ff ff       	call   801017a0 <ilock>
  if(ip->type != T_DIR){
80105356:	83 c4 10             	add    $0x10,%esp
80105359:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010535e:	75 30                	jne    80105390 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105360:	83 ec 0c             	sub    $0xc,%esp
80105363:	53                   	push   %ebx
80105364:	e8 17 c5 ff ff       	call   80101880 <iunlock>
  iput(curproc->cwd);
80105369:	58                   	pop    %eax
8010536a:	ff 76 68             	push   0x68(%esi)
8010536d:	e8 5e c5 ff ff       	call   801018d0 <iput>
  end_op();
80105372:	e8 39 da ff ff       	call   80102db0 <end_op>
  curproc->cwd = ip;
80105377:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
8010537a:	83 c4 10             	add    $0x10,%esp
8010537d:	31 c0                	xor    %eax,%eax
}
8010537f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105382:	5b                   	pop    %ebx
80105383:	5e                   	pop    %esi
80105384:	5d                   	pop    %ebp
80105385:	c3                   	ret
80105386:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010538d:	00 
8010538e:	66 90                	xchg   %ax,%ax
    iunlockput(ip);
80105390:	83 ec 0c             	sub    $0xc,%esp
80105393:	53                   	push   %ebx
80105394:	e8 97 c6 ff ff       	call   80101a30 <iunlockput>
    end_op();
80105399:	e8 12 da ff ff       	call   80102db0 <end_op>
    return -1;
8010539e:	83 c4 10             	add    $0x10,%esp
801053a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a6:	eb d7                	jmp    8010537f <sys_chdir+0x6f>
801053a8:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801053af:	00 
    end_op();
801053b0:	e8 fb d9 ff ff       	call   80102db0 <end_op>
    return -1;
801053b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053ba:	eb c3                	jmp    8010537f <sys_chdir+0x6f>
801053bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801053c0 <sys_exec>:

int
sys_exec(void)
{
801053c0:	55                   	push   %ebp
801053c1:	89 e5                	mov    %esp,%ebp
801053c3:	57                   	push   %edi
801053c4:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801053c5:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
801053cb:	53                   	push   %ebx
801053cc:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801053d2:	50                   	push   %eax
801053d3:	6a 00                	push   $0x0
801053d5:	e8 46 f5 ff ff       	call   80104920 <argstr>
801053da:	83 c4 10             	add    $0x10,%esp
801053dd:	85 c0                	test   %eax,%eax
801053df:	0f 88 87 00 00 00    	js     8010546c <sys_exec+0xac>
801053e5:	83 ec 08             	sub    $0x8,%esp
801053e8:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
801053ee:	50                   	push   %eax
801053ef:	6a 01                	push   $0x1
801053f1:	e8 7a f4 ff ff       	call   80104870 <argint>
801053f6:	83 c4 10             	add    $0x10,%esp
801053f9:	85 c0                	test   %eax,%eax
801053fb:	78 6f                	js     8010546c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801053fd:	83 ec 04             	sub    $0x4,%esp
80105400:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  for(i=0;; i++){
80105406:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105408:	68 80 00 00 00       	push   $0x80
8010540d:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
80105413:	6a 00                	push   $0x0
80105415:	50                   	push   %eax
80105416:	e8 95 f1 ff ff       	call   801045b0 <memset>
8010541b:	83 c4 10             	add    $0x10,%esp
8010541e:	66 90                	xchg   %ax,%ax
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105420:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105426:	8d 34 9d 00 00 00 00 	lea    0x0(,%ebx,4),%esi
8010542d:	83 ec 08             	sub    $0x8,%esp
80105430:	57                   	push   %edi
80105431:	01 f0                	add    %esi,%eax
80105433:	50                   	push   %eax
80105434:	e8 a7 f3 ff ff       	call   801047e0 <fetchint>
80105439:	83 c4 10             	add    $0x10,%esp
8010543c:	85 c0                	test   %eax,%eax
8010543e:	78 2c                	js     8010546c <sys_exec+0xac>
      return -1;
    if(uarg == 0){
80105440:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105446:	85 c0                	test   %eax,%eax
80105448:	74 36                	je     80105480 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010544a:	8d 8d 68 ff ff ff    	lea    -0x98(%ebp),%ecx
80105450:	83 ec 08             	sub    $0x8,%esp
80105453:	8d 14 31             	lea    (%ecx,%esi,1),%edx
80105456:	52                   	push   %edx
80105457:	50                   	push   %eax
80105458:	e8 c3 f3 ff ff       	call   80104820 <fetchstr>
8010545d:	83 c4 10             	add    $0x10,%esp
80105460:	85 c0                	test   %eax,%eax
80105462:	78 08                	js     8010546c <sys_exec+0xac>
  for(i=0;; i++){
80105464:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105467:	83 fb 20             	cmp    $0x20,%ebx
8010546a:	75 b4                	jne    80105420 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
8010546c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
8010546f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105474:	5b                   	pop    %ebx
80105475:	5e                   	pop    %esi
80105476:	5f                   	pop    %edi
80105477:	5d                   	pop    %ebp
80105478:	c3                   	ret
80105479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return exec(path, argv);
80105480:	83 ec 08             	sub    $0x8,%esp
80105483:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
      argv[i] = 0;
80105489:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105490:	00 00 00 00 
  return exec(path, argv);
80105494:	50                   	push   %eax
80105495:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
8010549b:	e8 10 b6 ff ff       	call   80100ab0 <exec>
801054a0:	83 c4 10             	add    $0x10,%esp
}
801054a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801054a6:	5b                   	pop    %ebx
801054a7:	5e                   	pop    %esi
801054a8:	5f                   	pop    %edi
801054a9:	5d                   	pop    %ebp
801054aa:	c3                   	ret
801054ab:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi

801054b0 <sys_pipe>:

int
sys_pipe(void)
{
801054b0:	55                   	push   %ebp
801054b1:	89 e5                	mov    %esp,%ebp
801054b3:	57                   	push   %edi
801054b4:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801054b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
801054b8:	53                   	push   %ebx
801054b9:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801054bc:	6a 08                	push   $0x8
801054be:	50                   	push   %eax
801054bf:	6a 00                	push   $0x0
801054c1:	e8 fa f3 ff ff       	call   801048c0 <argptr>
801054c6:	83 c4 10             	add    $0x10,%esp
801054c9:	85 c0                	test   %eax,%eax
801054cb:	78 4a                	js     80105517 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
801054cd:	83 ec 08             	sub    $0x8,%esp
801054d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801054d3:	50                   	push   %eax
801054d4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801054d7:	50                   	push   %eax
801054d8:	e8 f3 de ff ff       	call   801033d0 <pipealloc>
801054dd:	83 c4 10             	add    $0x10,%esp
801054e0:	85 c0                	test   %eax,%eax
801054e2:	78 33                	js     80105517 <sys_pipe+0x67>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801054e4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
801054e7:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
801054e9:	e8 32 e4 ff ff       	call   80103920 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801054ee:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
801054f0:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
801054f4:	85 f6                	test   %esi,%esi
801054f6:	74 28                	je     80105520 <sys_pipe+0x70>
  for(fd = 0; fd < NOFILE; fd++){
801054f8:	83 c3 01             	add    $0x1,%ebx
801054fb:	83 fb 10             	cmp    $0x10,%ebx
801054fe:	75 f0                	jne    801054f0 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80105500:	83 ec 0c             	sub    $0xc,%esp
80105503:	ff 75 e0             	push   -0x20(%ebp)
80105506:	e8 05 ba ff ff       	call   80100f10 <fileclose>
    fileclose(wf);
8010550b:	58                   	pop    %eax
8010550c:	ff 75 e4             	push   -0x1c(%ebp)
8010550f:	e8 fc b9 ff ff       	call   80100f10 <fileclose>
    return -1;
80105514:	83 c4 10             	add    $0x10,%esp
80105517:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010551c:	eb 53                	jmp    80105571 <sys_pipe+0xc1>
8010551e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105520:	8d 73 08             	lea    0x8(%ebx),%esi
80105523:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105527:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
8010552a:	e8 f1 e3 ff ff       	call   80103920 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010552f:	31 d2                	xor    %edx,%edx
80105531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80105538:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
8010553c:	85 c9                	test   %ecx,%ecx
8010553e:	74 20                	je     80105560 <sys_pipe+0xb0>
  for(fd = 0; fd < NOFILE; fd++){
80105540:	83 c2 01             	add    $0x1,%edx
80105543:	83 fa 10             	cmp    $0x10,%edx
80105546:	75 f0                	jne    80105538 <sys_pipe+0x88>
      myproc()->ofile[fd0] = 0;
80105548:	e8 d3 e3 ff ff       	call   80103920 <myproc>
8010554d:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
80105554:	00 
80105555:	eb a9                	jmp    80105500 <sys_pipe+0x50>
80105557:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010555e:	00 
8010555f:	90                   	nop
      curproc->ofile[fd] = f;
80105560:	89 7c 90 28          	mov    %edi,0x28(%eax,%edx,4)
  }
  fd[0] = fd0;
80105564:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105567:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105569:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010556c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
8010556f:	31 c0                	xor    %eax,%eax
}
80105571:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105574:	5b                   	pop    %ebx
80105575:	5e                   	pop    %esi
80105576:	5f                   	pop    %edi
80105577:	5d                   	pop    %ebp
80105578:	c3                   	ret
80105579:	66 90                	xchg   %ax,%ax
8010557b:	66 90                	xchg   %ax,%ax
8010557d:	66 90                	xchg   %ax,%ax
8010557f:	90                   	nop

80105580 <sys_fork>:
#include "proc.h"

int
sys_fork(void)
{
  return fork();
80105580:	e9 3b e5 ff ff       	jmp    80103ac0 <fork>
80105585:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010558c:	00 
8010558d:	8d 76 00             	lea    0x0(%esi),%esi

80105590 <sys_exit>:
}

int
sys_exit(void)
{
80105590:	55                   	push   %ebp
80105591:	89 e5                	mov    %esp,%ebp
80105593:	83 ec 08             	sub    $0x8,%esp
  exit();
80105596:	e8 a5 e7 ff ff       	call   80103d40 <exit>
  return 0;  // not reached
}
8010559b:	31 c0                	xor    %eax,%eax
8010559d:	c9                   	leave
8010559e:	c3                   	ret
8010559f:	90                   	nop

801055a0 <sys_wait>:

int
sys_wait(void)
{
  return wait();
801055a0:	e9 db e9 ff ff       	jmp    80103f80 <wait>
801055a5:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801055ac:	00 
801055ad:	8d 76 00             	lea    0x0(%esi),%esi

801055b0 <sys_kill>:
}

int
sys_kill(void)
{
801055b0:	55                   	push   %ebp
801055b1:	89 e5                	mov    %esp,%ebp
801055b3:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
801055b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055b9:	50                   	push   %eax
801055ba:	6a 00                	push   $0x0
801055bc:	e8 af f2 ff ff       	call   80104870 <argint>
801055c1:	83 c4 10             	add    $0x10,%esp
801055c4:	85 c0                	test   %eax,%eax
801055c6:	78 18                	js     801055e0 <sys_kill+0x30>
    return -1;
  return kill(pid);
801055c8:	83 ec 0c             	sub    $0xc,%esp
801055cb:	ff 75 f4             	push   -0xc(%ebp)
801055ce:	e8 fd ea ff ff       	call   801040d0 <kill>
801055d3:	83 c4 10             	add    $0x10,%esp
}
801055d6:	c9                   	leave
801055d7:	c3                   	ret
801055d8:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801055df:	00 
801055e0:	c9                   	leave
    return -1;
801055e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055e6:	c3                   	ret
801055e7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801055ee:	00 
801055ef:	90                   	nop

801055f0 <sys_getpid>:

int
sys_getpid(void)
{
801055f0:	55                   	push   %ebp
801055f1:	89 e5                	mov    %esp,%ebp
801055f3:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801055f6:	e8 25 e3 ff ff       	call   80103920 <myproc>
801055fb:	8b 40 10             	mov    0x10(%eax),%eax
}
801055fe:	c9                   	leave
801055ff:	c3                   	ret

80105600 <sys_sbrk>:

int
sys_sbrk(void)
{
80105600:	55                   	push   %ebp
80105601:	89 e5                	mov    %esp,%ebp
80105603:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105604:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105607:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
8010560a:	50                   	push   %eax
8010560b:	6a 00                	push   $0x0
8010560d:	e8 5e f2 ff ff       	call   80104870 <argint>
80105612:	83 c4 10             	add    $0x10,%esp
80105615:	85 c0                	test   %eax,%eax
80105617:	78 27                	js     80105640 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105619:	e8 02 e3 ff ff       	call   80103920 <myproc>
  if(growproc(n) < 0)
8010561e:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105621:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105623:	ff 75 f4             	push   -0xc(%ebp)
80105626:	e8 15 e4 ff ff       	call   80103a40 <growproc>
8010562b:	83 c4 10             	add    $0x10,%esp
8010562e:	85 c0                	test   %eax,%eax
80105630:	78 0e                	js     80105640 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105632:	89 d8                	mov    %ebx,%eax
80105634:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105637:	c9                   	leave
80105638:	c3                   	ret
80105639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105640:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105645:	eb eb                	jmp    80105632 <sys_sbrk+0x32>
80105647:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010564e:	00 
8010564f:	90                   	nop

80105650 <sys_sleep>:

int
sys_sleep(void)
{
80105650:	55                   	push   %ebp
80105651:	89 e5                	mov    %esp,%ebp
80105653:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105654:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105657:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
8010565a:	50                   	push   %eax
8010565b:	6a 00                	push   $0x0
8010565d:	e8 0e f2 ff ff       	call   80104870 <argint>
80105662:	83 c4 10             	add    $0x10,%esp
80105665:	85 c0                	test   %eax,%eax
80105667:	0f 88 8a 00 00 00    	js     801056f7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
8010566d:	83 ec 0c             	sub    $0xc,%esp
80105670:	68 40 cd 15 88       	push   $0x8815cd40
80105675:	e8 26 ee ff ff       	call   801044a0 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010567a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
8010567d:	8b 1d 80 d5 15 88    	mov    0x8815d580,%ebx
  while(ticks - ticks0 < n){
80105683:	83 c4 10             	add    $0x10,%esp
80105686:	85 d2                	test   %edx,%edx
80105688:	75 27                	jne    801056b1 <sys_sleep+0x61>
8010568a:	eb 54                	jmp    801056e0 <sys_sleep+0x90>
8010568c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105690:	83 ec 08             	sub    $0x8,%esp
80105693:	68 40 cd 15 88       	push   $0x8815cd40
80105698:	68 80 d5 15 88       	push   $0x8815d580
8010569d:	e8 1e e8 ff ff       	call   80103ec0 <sleep>
  while(ticks - ticks0 < n){
801056a2:	a1 80 d5 15 88       	mov    0x8815d580,%eax
801056a7:	83 c4 10             	add    $0x10,%esp
801056aa:	29 d8                	sub    %ebx,%eax
801056ac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801056af:	73 2f                	jae    801056e0 <sys_sleep+0x90>
    if(myproc()->killed){
801056b1:	e8 6a e2 ff ff       	call   80103920 <myproc>
801056b6:	8b 40 24             	mov    0x24(%eax),%eax
801056b9:	85 c0                	test   %eax,%eax
801056bb:	74 d3                	je     80105690 <sys_sleep+0x40>
      release(&tickslock);
801056bd:	83 ec 0c             	sub    $0xc,%esp
801056c0:	68 40 cd 15 88       	push   $0x8815cd40
801056c5:	e8 96 ee ff ff       	call   80104560 <release>
  }
  release(&tickslock);
  return 0;
}
801056ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
801056cd:	83 c4 10             	add    $0x10,%esp
801056d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056d5:	c9                   	leave
801056d6:	c3                   	ret
801056d7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801056de:	00 
801056df:	90                   	nop
  release(&tickslock);
801056e0:	83 ec 0c             	sub    $0xc,%esp
801056e3:	68 40 cd 15 88       	push   $0x8815cd40
801056e8:	e8 73 ee ff ff       	call   80104560 <release>
  return 0;
801056ed:	83 c4 10             	add    $0x10,%esp
801056f0:	31 c0                	xor    %eax,%eax
}
801056f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801056f5:	c9                   	leave
801056f6:	c3                   	ret
    return -1;
801056f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fc:	eb f4                	jmp    801056f2 <sys_sleep+0xa2>
801056fe:	66 90                	xchg   %ax,%ax

80105700 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105700:	55                   	push   %ebp
80105701:	89 e5                	mov    %esp,%ebp
80105703:	53                   	push   %ebx
80105704:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105707:	68 40 cd 15 88       	push   $0x8815cd40
8010570c:	e8 8f ed ff ff       	call   801044a0 <acquire>
  xticks = ticks;
80105711:	8b 1d 80 d5 15 88    	mov    0x8815d580,%ebx
  release(&tickslock);
80105717:	c7 04 24 40 cd 15 88 	movl   $0x8815cd40,(%esp)
8010571e:	e8 3d ee ff ff       	call   80104560 <release>
  return xticks;
}
80105723:	89 d8                	mov    %ebx,%eax
80105725:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105728:	c9                   	leave
80105729:	c3                   	ret

8010572a <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010572a:	1e                   	push   %ds
  pushl %es
8010572b:	06                   	push   %es
  pushl %fs
8010572c:	0f a0                	push   %fs
  pushl %gs
8010572e:	0f a8                	push   %gs
  pushal
80105730:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105731:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105735:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105737:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105739:	54                   	push   %esp
  call trap
8010573a:	e8 c1 00 00 00       	call   80105800 <trap>
  addl $4, %esp
8010573f:	83 c4 04             	add    $0x4,%esp

80105742 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105742:	61                   	popa
  popl %gs
80105743:	0f a9                	pop    %gs
  popl %fs
80105745:	0f a1                	pop    %fs
  popl %es
80105747:	07                   	pop    %es
  popl %ds
80105748:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105749:	83 c4 08             	add    $0x8,%esp
  iret
8010574c:	cf                   	iret
8010574d:	66 90                	xchg   %ax,%ax
8010574f:	90                   	nop

80105750 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105750:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105751:	31 c0                	xor    %eax,%eax
{
80105753:	89 e5                	mov    %esp,%ebp
80105755:	83 ec 08             	sub    $0x8,%esp
80105758:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010575f:	00 
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105760:	8b 14 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%edx
80105767:	c7 04 c5 82 cd 15 88 	movl   $0x8e000008,-0x77ea327e(,%eax,8)
8010576e:	08 00 00 8e 
80105772:	66 89 14 c5 80 cd 15 	mov    %dx,-0x77ea3280(,%eax,8)
80105779:	88 
8010577a:	c1 ea 10             	shr    $0x10,%edx
8010577d:	66 89 14 c5 86 cd 15 	mov    %dx,-0x77ea327a(,%eax,8)
80105784:	88 
  for(i = 0; i < 256; i++)
80105785:	83 c0 01             	add    $0x1,%eax
80105788:	3d 00 01 00 00       	cmp    $0x100,%eax
8010578d:	75 d1                	jne    80105760 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
8010578f:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105792:	a1 08 a1 10 80       	mov    0x8010a108,%eax
80105797:	c7 05 82 cf 15 88 08 	movl   $0xef000008,0x8815cf82
8010579e:	00 00 ef 
  initlock(&tickslock, "time");
801057a1:	68 4e 73 10 80       	push   $0x8010734e
801057a6:	68 40 cd 15 88       	push   $0x8815cd40
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801057ab:	66 a3 80 cf 15 88    	mov    %ax,0x8815cf80
801057b1:	c1 e8 10             	shr    $0x10,%eax
801057b4:	66 a3 86 cf 15 88    	mov    %ax,0x8815cf86
  initlock(&tickslock, "time");
801057ba:	e8 81 eb ff ff       	call   80104340 <initlock>
}
801057bf:	83 c4 10             	add    $0x10,%esp
801057c2:	c9                   	leave
801057c3:	c3                   	ret
801057c4:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801057cb:	00 
801057cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801057d0 <idtinit>:

void
idtinit(void)
{
801057d0:	55                   	push   %ebp
  pd[0] = size-1;
801057d1:	b8 ff 07 00 00       	mov    $0x7ff,%eax
801057d6:	89 e5                	mov    %esp,%ebp
801057d8:	83 ec 10             	sub    $0x10,%esp
801057db:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801057df:	b8 80 cd 15 88       	mov    $0x8815cd80,%eax
801057e4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801057e8:	c1 e8 10             	shr    $0x10,%eax
801057eb:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801057ef:	8d 45 fa             	lea    -0x6(%ebp),%eax
801057f2:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801057f5:	c9                   	leave
801057f6:	c3                   	ret
801057f7:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801057fe:	00 
801057ff:	90                   	nop

80105800 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105800:	55                   	push   %ebp
80105801:	89 e5                	mov    %esp,%ebp
80105803:	57                   	push   %edi
80105804:	56                   	push   %esi
80105805:	53                   	push   %ebx
80105806:	83 ec 1c             	sub    $0x1c,%esp
80105809:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010580c:	8b 43 30             	mov    0x30(%ebx),%eax
8010580f:	83 f8 40             	cmp    $0x40,%eax
80105812:	0f 84 c0 01 00 00    	je     801059d8 <trap+0x1d8>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105818:	83 e8 20             	sub    $0x20,%eax
8010581b:	83 f8 1f             	cmp    $0x1f,%eax
8010581e:	77 07                	ja     80105827 <trap+0x27>
80105820:	ff 24 85 b8 78 10 80 	jmp    *-0x7fef8748(,%eax,4)
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80105827:	e8 f4 e0 ff ff       	call   80103920 <myproc>
8010582c:	8b 7b 38             	mov    0x38(%ebx),%edi
8010582f:	85 c0                	test   %eax,%eax
80105831:	0f 84 f0 01 00 00    	je     80105a27 <trap+0x227>
80105837:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010583b:	0f 84 e6 01 00 00    	je     80105a27 <trap+0x227>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105841:	0f 20 d1             	mov    %cr2,%ecx
80105844:	89 4d d8             	mov    %ecx,-0x28(%ebp)
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105847:	e8 b4 e0 ff ff       	call   80103900 <cpuid>
8010584c:	8b 73 30             	mov    0x30(%ebx),%esi
8010584f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105852:	8b 43 34             	mov    0x34(%ebx),%eax
80105855:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80105858:	e8 c3 e0 ff ff       	call   80103920 <myproc>
8010585d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105860:	e8 bb e0 ff ff       	call   80103920 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105865:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105868:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010586b:	51                   	push   %ecx
8010586c:	57                   	push   %edi
8010586d:	52                   	push   %edx
8010586e:	ff 75 e4             	push   -0x1c(%ebp)
80105871:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
80105872:	8b 75 e0             	mov    -0x20(%ebp),%esi
80105875:	83 c6 6c             	add    $0x6c,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105878:	56                   	push   %esi
80105879:	ff 70 10             	push   0x10(%eax)
8010587c:	68 9c 75 10 80       	push   $0x8010759c
80105881:	e8 2a ae ff ff       	call   801006b0 <cprintf>
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80105886:	83 c4 20             	add    $0x20,%esp
80105889:	e8 92 e0 ff ff       	call   80103920 <myproc>
8010588e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105895:	e8 86 e0 ff ff       	call   80103920 <myproc>
8010589a:	85 c0                	test   %eax,%eax
8010589c:	74 1d                	je     801058bb <trap+0xbb>
8010589e:	e8 7d e0 ff ff       	call   80103920 <myproc>
801058a3:	8b 50 24             	mov    0x24(%eax),%edx
801058a6:	85 d2                	test   %edx,%edx
801058a8:	74 11                	je     801058bb <trap+0xbb>
801058aa:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801058ae:	83 e0 03             	and    $0x3,%eax
801058b1:	66 83 f8 03          	cmp    $0x3,%ax
801058b5:	0f 84 55 01 00 00    	je     80105a10 <trap+0x210>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801058bb:	e8 60 e0 ff ff       	call   80103920 <myproc>
801058c0:	85 c0                	test   %eax,%eax
801058c2:	74 0f                	je     801058d3 <trap+0xd3>
801058c4:	e8 57 e0 ff ff       	call   80103920 <myproc>
801058c9:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801058cd:	0f 84 ed 00 00 00    	je     801059c0 <trap+0x1c0>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801058d3:	e8 48 e0 ff ff       	call   80103920 <myproc>
801058d8:	85 c0                	test   %eax,%eax
801058da:	74 1d                	je     801058f9 <trap+0xf9>
801058dc:	e8 3f e0 ff ff       	call   80103920 <myproc>
801058e1:	8b 40 24             	mov    0x24(%eax),%eax
801058e4:	85 c0                	test   %eax,%eax
801058e6:	74 11                	je     801058f9 <trap+0xf9>
801058e8:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801058ec:	83 e0 03             	and    $0x3,%eax
801058ef:	66 83 f8 03          	cmp    $0x3,%ax
801058f3:	0f 84 08 01 00 00    	je     80105a01 <trap+0x201>
    exit();
}
801058f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801058fc:	5b                   	pop    %ebx
801058fd:	5e                   	pop    %esi
801058fe:	5f                   	pop    %edi
801058ff:	5d                   	pop    %ebp
80105900:	c3                   	ret
    ideintr();
80105901:	e8 2a c9 ff ff       	call   80102230 <ideintr>
    lapiceoi();
80105906:	e8 e5 cf ff ff       	call   801028f0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010590b:	e8 10 e0 ff ff       	call   80103920 <myproc>
80105910:	85 c0                	test   %eax,%eax
80105912:	75 8a                	jne    8010589e <trap+0x9e>
80105914:	eb a5                	jmp    801058bb <trap+0xbb>
    if(cpuid() == 0){
80105916:	e8 e5 df ff ff       	call   80103900 <cpuid>
8010591b:	85 c0                	test   %eax,%eax
8010591d:	75 e7                	jne    80105906 <trap+0x106>
      acquire(&tickslock);
8010591f:	83 ec 0c             	sub    $0xc,%esp
80105922:	68 40 cd 15 88       	push   $0x8815cd40
80105927:	e8 74 eb ff ff       	call   801044a0 <acquire>
      wakeup(&ticks);
8010592c:	c7 04 24 80 d5 15 88 	movl   $0x8815d580,(%esp)
      ticks++;
80105933:	83 05 80 d5 15 88 01 	addl   $0x1,0x8815d580
      wakeup(&ticks);
8010593a:	e8 31 e7 ff ff       	call   80104070 <wakeup>
      release(&tickslock);
8010593f:	c7 04 24 40 cd 15 88 	movl   $0x8815cd40,(%esp)
80105946:	e8 15 ec ff ff       	call   80104560 <release>
8010594b:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010594e:	eb b6                	jmp    80105906 <trap+0x106>
    kbdintr();
80105950:	e8 6b ce ff ff       	call   801027c0 <kbdintr>
    lapiceoi();
80105955:	e8 96 cf ff ff       	call   801028f0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010595a:	e8 c1 df ff ff       	call   80103920 <myproc>
8010595f:	85 c0                	test   %eax,%eax
80105961:	0f 85 37 ff ff ff    	jne    8010589e <trap+0x9e>
80105967:	e9 4f ff ff ff       	jmp    801058bb <trap+0xbb>
    uartintr();
8010596c:	e8 3f 02 00 00       	call   80105bb0 <uartintr>
    lapiceoi();
80105971:	e8 7a cf ff ff       	call   801028f0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105976:	e8 a5 df ff ff       	call   80103920 <myproc>
8010597b:	85 c0                	test   %eax,%eax
8010597d:	0f 85 1b ff ff ff    	jne    8010589e <trap+0x9e>
80105983:	e9 33 ff ff ff       	jmp    801058bb <trap+0xbb>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105988:	8b 7b 38             	mov    0x38(%ebx),%edi
8010598b:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
8010598f:	e8 6c df ff ff       	call   80103900 <cpuid>
80105994:	57                   	push   %edi
80105995:	56                   	push   %esi
80105996:	50                   	push   %eax
80105997:	68 44 75 10 80       	push   $0x80107544
8010599c:	e8 0f ad ff ff       	call   801006b0 <cprintf>
    lapiceoi();
801059a1:	e8 4a cf ff ff       	call   801028f0 <lapiceoi>
    break;
801059a6:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801059a9:	e8 72 df ff ff       	call   80103920 <myproc>
801059ae:	85 c0                	test   %eax,%eax
801059b0:	0f 85 e8 fe ff ff    	jne    8010589e <trap+0x9e>
801059b6:	e9 00 ff ff ff       	jmp    801058bb <trap+0xbb>
801059bb:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
  if(myproc() && myproc()->state == RUNNING &&
801059c0:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801059c4:	0f 85 09 ff ff ff    	jne    801058d3 <trap+0xd3>
    yield();
801059ca:	e8 a1 e4 ff ff       	call   80103e70 <yield>
801059cf:	e9 ff fe ff ff       	jmp    801058d3 <trap+0xd3>
801059d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed)
801059d8:	e8 43 df ff ff       	call   80103920 <myproc>
801059dd:	8b 70 24             	mov    0x24(%eax),%esi
801059e0:	85 f6                	test   %esi,%esi
801059e2:	75 3c                	jne    80105a20 <trap+0x220>
    myproc()->tf = tf;
801059e4:	e8 37 df ff ff       	call   80103920 <myproc>
801059e9:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
801059ec:	e8 6f ef ff ff       	call   80104960 <syscall>
    if(myproc()->killed)
801059f1:	e8 2a df ff ff       	call   80103920 <myproc>
801059f6:	8b 48 24             	mov    0x24(%eax),%ecx
801059f9:	85 c9                	test   %ecx,%ecx
801059fb:	0f 84 f8 fe ff ff    	je     801058f9 <trap+0xf9>
}
80105a01:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105a04:	5b                   	pop    %ebx
80105a05:	5e                   	pop    %esi
80105a06:	5f                   	pop    %edi
80105a07:	5d                   	pop    %ebp
      exit();
80105a08:	e9 33 e3 ff ff       	jmp    80103d40 <exit>
80105a0d:	8d 76 00             	lea    0x0(%esi),%esi
    exit();
80105a10:	e8 2b e3 ff ff       	call   80103d40 <exit>
80105a15:	e9 a1 fe ff ff       	jmp    801058bb <trap+0xbb>
80105a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
80105a20:	e8 1b e3 ff ff       	call   80103d40 <exit>
80105a25:	eb bd                	jmp    801059e4 <trap+0x1e4>
80105a27:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105a2a:	e8 d1 de ff ff       	call   80103900 <cpuid>
80105a2f:	83 ec 0c             	sub    $0xc,%esp
80105a32:	56                   	push   %esi
80105a33:	57                   	push   %edi
80105a34:	50                   	push   %eax
80105a35:	ff 73 30             	push   0x30(%ebx)
80105a38:	68 68 75 10 80       	push   $0x80107568
80105a3d:	e8 6e ac ff ff       	call   801006b0 <cprintf>
      panic("trap");
80105a42:	83 c4 14             	add    $0x14,%esp
80105a45:	68 53 73 10 80       	push   $0x80107353
80105a4a:	e8 31 a9 ff ff       	call   80100380 <panic>
80105a4f:	90                   	nop

80105a50 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80105a50:	a1 28 98 15 88       	mov    0x88159828,%eax
80105a55:	85 c0                	test   %eax,%eax
80105a57:	74 17                	je     80105a70 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105a59:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105a5e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105a5f:	a8 01                	test   $0x1,%al
80105a61:	74 0d                	je     80105a70 <uartgetc+0x20>
80105a63:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105a68:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105a69:	0f b6 c0             	movzbl %al,%eax
80105a6c:	c3                   	ret
80105a6d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105a70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a75:	c3                   	ret
80105a76:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80105a7d:	00 
80105a7e:	66 90                	xchg   %ax,%ax

80105a80 <uartputc.part.0>:
uartputc(int c)
80105a80:	55                   	push   %ebp
80105a81:	89 e5                	mov    %esp,%ebp
80105a83:	57                   	push   %edi
80105a84:	89 c7                	mov    %eax,%edi
80105a86:	56                   	push   %esi
80105a87:	be fd 03 00 00       	mov    $0x3fd,%esi
80105a8c:	53                   	push   %ebx
80105a8d:	bb 80 00 00 00       	mov    $0x80,%ebx
80105a92:	83 ec 0c             	sub    $0xc,%esp
80105a95:	eb 1b                	jmp    80105ab2 <uartputc.part.0+0x32>
80105a97:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80105a9e:	00 
80105a9f:	90                   	nop
    microdelay(10);
80105aa0:	83 ec 0c             	sub    $0xc,%esp
80105aa3:	6a 0a                	push   $0xa
80105aa5:	e8 66 ce ff ff       	call   80102910 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105aaa:	83 c4 10             	add    $0x10,%esp
80105aad:	83 eb 01             	sub    $0x1,%ebx
80105ab0:	74 07                	je     80105ab9 <uartputc.part.0+0x39>
80105ab2:	89 f2                	mov    %esi,%edx
80105ab4:	ec                   	in     (%dx),%al
80105ab5:	a8 20                	test   $0x20,%al
80105ab7:	74 e7                	je     80105aa0 <uartputc.part.0+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105ab9:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105abe:	89 f8                	mov    %edi,%eax
80105ac0:	ee                   	out    %al,(%dx)
}
80105ac1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ac4:	5b                   	pop    %ebx
80105ac5:	5e                   	pop    %esi
80105ac6:	5f                   	pop    %edi
80105ac7:	5d                   	pop    %ebp
80105ac8:	c3                   	ret
80105ac9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105ad0 <uartinit>:
{
80105ad0:	55                   	push   %ebp
80105ad1:	31 c9                	xor    %ecx,%ecx
80105ad3:	89 c8                	mov    %ecx,%eax
80105ad5:	89 e5                	mov    %esp,%ebp
80105ad7:	57                   	push   %edi
80105ad8:	56                   	push   %esi
80105ad9:	53                   	push   %ebx
80105ada:	bb fa 03 00 00       	mov    $0x3fa,%ebx
80105adf:	89 da                	mov    %ebx,%edx
80105ae1:	83 ec 0c             	sub    $0xc,%esp
80105ae4:	ee                   	out    %al,(%dx)
80105ae5:	bf fb 03 00 00       	mov    $0x3fb,%edi
80105aea:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105aef:	89 fa                	mov    %edi,%edx
80105af1:	ee                   	out    %al,(%dx)
80105af2:	b8 0c 00 00 00       	mov    $0xc,%eax
80105af7:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105afc:	ee                   	out    %al,(%dx)
80105afd:	be f9 03 00 00       	mov    $0x3f9,%esi
80105b02:	89 c8                	mov    %ecx,%eax
80105b04:	89 f2                	mov    %esi,%edx
80105b06:	ee                   	out    %al,(%dx)
80105b07:	b8 03 00 00 00       	mov    $0x3,%eax
80105b0c:	89 fa                	mov    %edi,%edx
80105b0e:	ee                   	out    %al,(%dx)
80105b0f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105b14:	89 c8                	mov    %ecx,%eax
80105b16:	ee                   	out    %al,(%dx)
80105b17:	b8 01 00 00 00       	mov    $0x1,%eax
80105b1c:	89 f2                	mov    %esi,%edx
80105b1e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105b1f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105b24:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105b25:	3c ff                	cmp    $0xff,%al
80105b27:	74 49                	je     80105b72 <uartinit+0xa2>
  uart = 1;
80105b29:	c7 05 28 98 15 88 01 	movl   $0x1,0x88159828
80105b30:	00 00 00 
80105b33:	89 da                	mov    %ebx,%edx
80105b35:	ec                   	in     (%dx),%al
80105b36:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105b3b:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105b3c:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
80105b3f:	bb 58 73 10 80       	mov    $0x80107358,%ebx
  ioapicenable(IRQ_COM1, 0);
80105b44:	6a 00                	push   $0x0
80105b46:	6a 04                	push   $0x4
80105b48:	e8 13 c9 ff ff       	call   80102460 <ioapicenable>
80105b4d:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80105b50:	b8 78 00 00 00       	mov    $0x78,%eax
80105b55:	8d 76 00             	lea    0x0(%esi),%esi
  if(!uart)
80105b58:	8b 15 28 98 15 88    	mov    0x88159828,%edx
80105b5e:	85 d2                	test   %edx,%edx
80105b60:	74 05                	je     80105b67 <uartinit+0x97>
80105b62:	e8 19 ff ff ff       	call   80105a80 <uartputc.part.0>
  for(p="xv6...\n"; *p; p++)
80105b67:	0f be 43 01          	movsbl 0x1(%ebx),%eax
80105b6b:	83 c3 01             	add    $0x1,%ebx
80105b6e:	84 c0                	test   %al,%al
80105b70:	75 e6                	jne    80105b58 <uartinit+0x88>
}
80105b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105b75:	5b                   	pop    %ebx
80105b76:	5e                   	pop    %esi
80105b77:	5f                   	pop    %edi
80105b78:	5d                   	pop    %ebp
80105b79:	c3                   	ret
80105b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105b80 <uartputc>:
{
80105b80:	55                   	push   %ebp
  if(!uart)
80105b81:	8b 15 28 98 15 88    	mov    0x88159828,%edx
{
80105b87:	89 e5                	mov    %esp,%ebp
80105b89:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
80105b8c:	85 d2                	test   %edx,%edx
80105b8e:	74 10                	je     80105ba0 <uartputc+0x20>
}
80105b90:	5d                   	pop    %ebp
80105b91:	e9 ea fe ff ff       	jmp    80105a80 <uartputc.part.0>
80105b96:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80105b9d:	00 
80105b9e:	66 90                	xchg   %ax,%ax
80105ba0:	5d                   	pop    %ebp
80105ba1:	c3                   	ret
80105ba2:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80105ba9:	00 
80105baa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105bb0 <uartintr>:

void
uartintr(void)
{
80105bb0:	55                   	push   %ebp
80105bb1:	89 e5                	mov    %esp,%ebp
80105bb3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105bb6:	68 50 5a 10 80       	push   $0x80105a50
80105bbb:	e8 e0 ac ff ff       	call   801008a0 <consoleintr>
}
80105bc0:	83 c4 10             	add    $0x10,%esp
80105bc3:	c9                   	leave
80105bc4:	c3                   	ret

80105bc5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105bc5:	6a 00                	push   $0x0
  pushl $0
80105bc7:	6a 00                	push   $0x0
  jmp alltraps
80105bc9:	e9 5c fb ff ff       	jmp    8010572a <alltraps>

80105bce <vector1>:
.globl vector1
vector1:
  pushl $0
80105bce:	6a 00                	push   $0x0
  pushl $1
80105bd0:	6a 01                	push   $0x1
  jmp alltraps
80105bd2:	e9 53 fb ff ff       	jmp    8010572a <alltraps>

80105bd7 <vector2>:
.globl vector2
vector2:
  pushl $0
80105bd7:	6a 00                	push   $0x0
  pushl $2
80105bd9:	6a 02                	push   $0x2
  jmp alltraps
80105bdb:	e9 4a fb ff ff       	jmp    8010572a <alltraps>

80105be0 <vector3>:
.globl vector3
vector3:
  pushl $0
80105be0:	6a 00                	push   $0x0
  pushl $3
80105be2:	6a 03                	push   $0x3
  jmp alltraps
80105be4:	e9 41 fb ff ff       	jmp    8010572a <alltraps>

80105be9 <vector4>:
.globl vector4
vector4:
  pushl $0
80105be9:	6a 00                	push   $0x0
  pushl $4
80105beb:	6a 04                	push   $0x4
  jmp alltraps
80105bed:	e9 38 fb ff ff       	jmp    8010572a <alltraps>

80105bf2 <vector5>:
.globl vector5
vector5:
  pushl $0
80105bf2:	6a 00                	push   $0x0
  pushl $5
80105bf4:	6a 05                	push   $0x5
  jmp alltraps
80105bf6:	e9 2f fb ff ff       	jmp    8010572a <alltraps>

80105bfb <vector6>:
.globl vector6
vector6:
  pushl $0
80105bfb:	6a 00                	push   $0x0
  pushl $6
80105bfd:	6a 06                	push   $0x6
  jmp alltraps
80105bff:	e9 26 fb ff ff       	jmp    8010572a <alltraps>

80105c04 <vector7>:
.globl vector7
vector7:
  pushl $0
80105c04:	6a 00                	push   $0x0
  pushl $7
80105c06:	6a 07                	push   $0x7
  jmp alltraps
80105c08:	e9 1d fb ff ff       	jmp    8010572a <alltraps>

80105c0d <vector8>:
.globl vector8
vector8:
  pushl $8
80105c0d:	6a 08                	push   $0x8
  jmp alltraps
80105c0f:	e9 16 fb ff ff       	jmp    8010572a <alltraps>

80105c14 <vector9>:
.globl vector9
vector9:
  pushl $0
80105c14:	6a 00                	push   $0x0
  pushl $9
80105c16:	6a 09                	push   $0x9
  jmp alltraps
80105c18:	e9 0d fb ff ff       	jmp    8010572a <alltraps>

80105c1d <vector10>:
.globl vector10
vector10:
  pushl $10
80105c1d:	6a 0a                	push   $0xa
  jmp alltraps
80105c1f:	e9 06 fb ff ff       	jmp    8010572a <alltraps>

80105c24 <vector11>:
.globl vector11
vector11:
  pushl $11
80105c24:	6a 0b                	push   $0xb
  jmp alltraps
80105c26:	e9 ff fa ff ff       	jmp    8010572a <alltraps>

80105c2b <vector12>:
.globl vector12
vector12:
  pushl $12
80105c2b:	6a 0c                	push   $0xc
  jmp alltraps
80105c2d:	e9 f8 fa ff ff       	jmp    8010572a <alltraps>

80105c32 <vector13>:
.globl vector13
vector13:
  pushl $13
80105c32:	6a 0d                	push   $0xd
  jmp alltraps
80105c34:	e9 f1 fa ff ff       	jmp    8010572a <alltraps>

80105c39 <vector14>:
.globl vector14
vector14:
  pushl $14
80105c39:	6a 0e                	push   $0xe
  jmp alltraps
80105c3b:	e9 ea fa ff ff       	jmp    8010572a <alltraps>

80105c40 <vector15>:
.globl vector15
vector15:
  pushl $0
80105c40:	6a 00                	push   $0x0
  pushl $15
80105c42:	6a 0f                	push   $0xf
  jmp alltraps
80105c44:	e9 e1 fa ff ff       	jmp    8010572a <alltraps>

80105c49 <vector16>:
.globl vector16
vector16:
  pushl $0
80105c49:	6a 00                	push   $0x0
  pushl $16
80105c4b:	6a 10                	push   $0x10
  jmp alltraps
80105c4d:	e9 d8 fa ff ff       	jmp    8010572a <alltraps>

80105c52 <vector17>:
.globl vector17
vector17:
  pushl $17
80105c52:	6a 11                	push   $0x11
  jmp alltraps
80105c54:	e9 d1 fa ff ff       	jmp    8010572a <alltraps>

80105c59 <vector18>:
.globl vector18
vector18:
  pushl $0
80105c59:	6a 00                	push   $0x0
  pushl $18
80105c5b:	6a 12                	push   $0x12
  jmp alltraps
80105c5d:	e9 c8 fa ff ff       	jmp    8010572a <alltraps>

80105c62 <vector19>:
.globl vector19
vector19:
  pushl $0
80105c62:	6a 00                	push   $0x0
  pushl $19
80105c64:	6a 13                	push   $0x13
  jmp alltraps
80105c66:	e9 bf fa ff ff       	jmp    8010572a <alltraps>

80105c6b <vector20>:
.globl vector20
vector20:
  pushl $0
80105c6b:	6a 00                	push   $0x0
  pushl $20
80105c6d:	6a 14                	push   $0x14
  jmp alltraps
80105c6f:	e9 b6 fa ff ff       	jmp    8010572a <alltraps>

80105c74 <vector21>:
.globl vector21
vector21:
  pushl $0
80105c74:	6a 00                	push   $0x0
  pushl $21
80105c76:	6a 15                	push   $0x15
  jmp alltraps
80105c78:	e9 ad fa ff ff       	jmp    8010572a <alltraps>

80105c7d <vector22>:
.globl vector22
vector22:
  pushl $0
80105c7d:	6a 00                	push   $0x0
  pushl $22
80105c7f:	6a 16                	push   $0x16
  jmp alltraps
80105c81:	e9 a4 fa ff ff       	jmp    8010572a <alltraps>

80105c86 <vector23>:
.globl vector23
vector23:
  pushl $0
80105c86:	6a 00                	push   $0x0
  pushl $23
80105c88:	6a 17                	push   $0x17
  jmp alltraps
80105c8a:	e9 9b fa ff ff       	jmp    8010572a <alltraps>

80105c8f <vector24>:
.globl vector24
vector24:
  pushl $0
80105c8f:	6a 00                	push   $0x0
  pushl $24
80105c91:	6a 18                	push   $0x18
  jmp alltraps
80105c93:	e9 92 fa ff ff       	jmp    8010572a <alltraps>

80105c98 <vector25>:
.globl vector25
vector25:
  pushl $0
80105c98:	6a 00                	push   $0x0
  pushl $25
80105c9a:	6a 19                	push   $0x19
  jmp alltraps
80105c9c:	e9 89 fa ff ff       	jmp    8010572a <alltraps>

80105ca1 <vector26>:
.globl vector26
vector26:
  pushl $0
80105ca1:	6a 00                	push   $0x0
  pushl $26
80105ca3:	6a 1a                	push   $0x1a
  jmp alltraps
80105ca5:	e9 80 fa ff ff       	jmp    8010572a <alltraps>

80105caa <vector27>:
.globl vector27
vector27:
  pushl $0
80105caa:	6a 00                	push   $0x0
  pushl $27
80105cac:	6a 1b                	push   $0x1b
  jmp alltraps
80105cae:	e9 77 fa ff ff       	jmp    8010572a <alltraps>

80105cb3 <vector28>:
.globl vector28
vector28:
  pushl $0
80105cb3:	6a 00                	push   $0x0
  pushl $28
80105cb5:	6a 1c                	push   $0x1c
  jmp alltraps
80105cb7:	e9 6e fa ff ff       	jmp    8010572a <alltraps>

80105cbc <vector29>:
.globl vector29
vector29:
  pushl $0
80105cbc:	6a 00                	push   $0x0
  pushl $29
80105cbe:	6a 1d                	push   $0x1d
  jmp alltraps
80105cc0:	e9 65 fa ff ff       	jmp    8010572a <alltraps>

80105cc5 <vector30>:
.globl vector30
vector30:
  pushl $0
80105cc5:	6a 00                	push   $0x0
  pushl $30
80105cc7:	6a 1e                	push   $0x1e
  jmp alltraps
80105cc9:	e9 5c fa ff ff       	jmp    8010572a <alltraps>

80105cce <vector31>:
.globl vector31
vector31:
  pushl $0
80105cce:	6a 00                	push   $0x0
  pushl $31
80105cd0:	6a 1f                	push   $0x1f
  jmp alltraps
80105cd2:	e9 53 fa ff ff       	jmp    8010572a <alltraps>

80105cd7 <vector32>:
.globl vector32
vector32:
  pushl $0
80105cd7:	6a 00                	push   $0x0
  pushl $32
80105cd9:	6a 20                	push   $0x20
  jmp alltraps
80105cdb:	e9 4a fa ff ff       	jmp    8010572a <alltraps>

80105ce0 <vector33>:
.globl vector33
vector33:
  pushl $0
80105ce0:	6a 00                	push   $0x0
  pushl $33
80105ce2:	6a 21                	push   $0x21
  jmp alltraps
80105ce4:	e9 41 fa ff ff       	jmp    8010572a <alltraps>

80105ce9 <vector34>:
.globl vector34
vector34:
  pushl $0
80105ce9:	6a 00                	push   $0x0
  pushl $34
80105ceb:	6a 22                	push   $0x22
  jmp alltraps
80105ced:	e9 38 fa ff ff       	jmp    8010572a <alltraps>

80105cf2 <vector35>:
.globl vector35
vector35:
  pushl $0
80105cf2:	6a 00                	push   $0x0
  pushl $35
80105cf4:	6a 23                	push   $0x23
  jmp alltraps
80105cf6:	e9 2f fa ff ff       	jmp    8010572a <alltraps>

80105cfb <vector36>:
.globl vector36
vector36:
  pushl $0
80105cfb:	6a 00                	push   $0x0
  pushl $36
80105cfd:	6a 24                	push   $0x24
  jmp alltraps
80105cff:	e9 26 fa ff ff       	jmp    8010572a <alltraps>

80105d04 <vector37>:
.globl vector37
vector37:
  pushl $0
80105d04:	6a 00                	push   $0x0
  pushl $37
80105d06:	6a 25                	push   $0x25
  jmp alltraps
80105d08:	e9 1d fa ff ff       	jmp    8010572a <alltraps>

80105d0d <vector38>:
.globl vector38
vector38:
  pushl $0
80105d0d:	6a 00                	push   $0x0
  pushl $38
80105d0f:	6a 26                	push   $0x26
  jmp alltraps
80105d11:	e9 14 fa ff ff       	jmp    8010572a <alltraps>

80105d16 <vector39>:
.globl vector39
vector39:
  pushl $0
80105d16:	6a 00                	push   $0x0
  pushl $39
80105d18:	6a 27                	push   $0x27
  jmp alltraps
80105d1a:	e9 0b fa ff ff       	jmp    8010572a <alltraps>

80105d1f <vector40>:
.globl vector40
vector40:
  pushl $0
80105d1f:	6a 00                	push   $0x0
  pushl $40
80105d21:	6a 28                	push   $0x28
  jmp alltraps
80105d23:	e9 02 fa ff ff       	jmp    8010572a <alltraps>

80105d28 <vector41>:
.globl vector41
vector41:
  pushl $0
80105d28:	6a 00                	push   $0x0
  pushl $41
80105d2a:	6a 29                	push   $0x29
  jmp alltraps
80105d2c:	e9 f9 f9 ff ff       	jmp    8010572a <alltraps>

80105d31 <vector42>:
.globl vector42
vector42:
  pushl $0
80105d31:	6a 00                	push   $0x0
  pushl $42
80105d33:	6a 2a                	push   $0x2a
  jmp alltraps
80105d35:	e9 f0 f9 ff ff       	jmp    8010572a <alltraps>

80105d3a <vector43>:
.globl vector43
vector43:
  pushl $0
80105d3a:	6a 00                	push   $0x0
  pushl $43
80105d3c:	6a 2b                	push   $0x2b
  jmp alltraps
80105d3e:	e9 e7 f9 ff ff       	jmp    8010572a <alltraps>

80105d43 <vector44>:
.globl vector44
vector44:
  pushl $0
80105d43:	6a 00                	push   $0x0
  pushl $44
80105d45:	6a 2c                	push   $0x2c
  jmp alltraps
80105d47:	e9 de f9 ff ff       	jmp    8010572a <alltraps>

80105d4c <vector45>:
.globl vector45
vector45:
  pushl $0
80105d4c:	6a 00                	push   $0x0
  pushl $45
80105d4e:	6a 2d                	push   $0x2d
  jmp alltraps
80105d50:	e9 d5 f9 ff ff       	jmp    8010572a <alltraps>

80105d55 <vector46>:
.globl vector46
vector46:
  pushl $0
80105d55:	6a 00                	push   $0x0
  pushl $46
80105d57:	6a 2e                	push   $0x2e
  jmp alltraps
80105d59:	e9 cc f9 ff ff       	jmp    8010572a <alltraps>

80105d5e <vector47>:
.globl vector47
vector47:
  pushl $0
80105d5e:	6a 00                	push   $0x0
  pushl $47
80105d60:	6a 2f                	push   $0x2f
  jmp alltraps
80105d62:	e9 c3 f9 ff ff       	jmp    8010572a <alltraps>

80105d67 <vector48>:
.globl vector48
vector48:
  pushl $0
80105d67:	6a 00                	push   $0x0
  pushl $48
80105d69:	6a 30                	push   $0x30
  jmp alltraps
80105d6b:	e9 ba f9 ff ff       	jmp    8010572a <alltraps>

80105d70 <vector49>:
.globl vector49
vector49:
  pushl $0
80105d70:	6a 00                	push   $0x0
  pushl $49
80105d72:	6a 31                	push   $0x31
  jmp alltraps
80105d74:	e9 b1 f9 ff ff       	jmp    8010572a <alltraps>

80105d79 <vector50>:
.globl vector50
vector50:
  pushl $0
80105d79:	6a 00                	push   $0x0
  pushl $50
80105d7b:	6a 32                	push   $0x32
  jmp alltraps
80105d7d:	e9 a8 f9 ff ff       	jmp    8010572a <alltraps>

80105d82 <vector51>:
.globl vector51
vector51:
  pushl $0
80105d82:	6a 00                	push   $0x0
  pushl $51
80105d84:	6a 33                	push   $0x33
  jmp alltraps
80105d86:	e9 9f f9 ff ff       	jmp    8010572a <alltraps>

80105d8b <vector52>:
.globl vector52
vector52:
  pushl $0
80105d8b:	6a 00                	push   $0x0
  pushl $52
80105d8d:	6a 34                	push   $0x34
  jmp alltraps
80105d8f:	e9 96 f9 ff ff       	jmp    8010572a <alltraps>

80105d94 <vector53>:
.globl vector53
vector53:
  pushl $0
80105d94:	6a 00                	push   $0x0
  pushl $53
80105d96:	6a 35                	push   $0x35
  jmp alltraps
80105d98:	e9 8d f9 ff ff       	jmp    8010572a <alltraps>

80105d9d <vector54>:
.globl vector54
vector54:
  pushl $0
80105d9d:	6a 00                	push   $0x0
  pushl $54
80105d9f:	6a 36                	push   $0x36
  jmp alltraps
80105da1:	e9 84 f9 ff ff       	jmp    8010572a <alltraps>

80105da6 <vector55>:
.globl vector55
vector55:
  pushl $0
80105da6:	6a 00                	push   $0x0
  pushl $55
80105da8:	6a 37                	push   $0x37
  jmp alltraps
80105daa:	e9 7b f9 ff ff       	jmp    8010572a <alltraps>

80105daf <vector56>:
.globl vector56
vector56:
  pushl $0
80105daf:	6a 00                	push   $0x0
  pushl $56
80105db1:	6a 38                	push   $0x38
  jmp alltraps
80105db3:	e9 72 f9 ff ff       	jmp    8010572a <alltraps>

80105db8 <vector57>:
.globl vector57
vector57:
  pushl $0
80105db8:	6a 00                	push   $0x0
  pushl $57
80105dba:	6a 39                	push   $0x39
  jmp alltraps
80105dbc:	e9 69 f9 ff ff       	jmp    8010572a <alltraps>

80105dc1 <vector58>:
.globl vector58
vector58:
  pushl $0
80105dc1:	6a 00                	push   $0x0
  pushl $58
80105dc3:	6a 3a                	push   $0x3a
  jmp alltraps
80105dc5:	e9 60 f9 ff ff       	jmp    8010572a <alltraps>

80105dca <vector59>:
.globl vector59
vector59:
  pushl $0
80105dca:	6a 00                	push   $0x0
  pushl $59
80105dcc:	6a 3b                	push   $0x3b
  jmp alltraps
80105dce:	e9 57 f9 ff ff       	jmp    8010572a <alltraps>

80105dd3 <vector60>:
.globl vector60
vector60:
  pushl $0
80105dd3:	6a 00                	push   $0x0
  pushl $60
80105dd5:	6a 3c                	push   $0x3c
  jmp alltraps
80105dd7:	e9 4e f9 ff ff       	jmp    8010572a <alltraps>

80105ddc <vector61>:
.globl vector61
vector61:
  pushl $0
80105ddc:	6a 00                	push   $0x0
  pushl $61
80105dde:	6a 3d                	push   $0x3d
  jmp alltraps
80105de0:	e9 45 f9 ff ff       	jmp    8010572a <alltraps>

80105de5 <vector62>:
.globl vector62
vector62:
  pushl $0
80105de5:	6a 00                	push   $0x0
  pushl $62
80105de7:	6a 3e                	push   $0x3e
  jmp alltraps
80105de9:	e9 3c f9 ff ff       	jmp    8010572a <alltraps>

80105dee <vector63>:
.globl vector63
vector63:
  pushl $0
80105dee:	6a 00                	push   $0x0
  pushl $63
80105df0:	6a 3f                	push   $0x3f
  jmp alltraps
80105df2:	e9 33 f9 ff ff       	jmp    8010572a <alltraps>

80105df7 <vector64>:
.globl vector64
vector64:
  pushl $0
80105df7:	6a 00                	push   $0x0
  pushl $64
80105df9:	6a 40                	push   $0x40
  jmp alltraps
80105dfb:	e9 2a f9 ff ff       	jmp    8010572a <alltraps>

80105e00 <vector65>:
.globl vector65
vector65:
  pushl $0
80105e00:	6a 00                	push   $0x0
  pushl $65
80105e02:	6a 41                	push   $0x41
  jmp alltraps
80105e04:	e9 21 f9 ff ff       	jmp    8010572a <alltraps>

80105e09 <vector66>:
.globl vector66
vector66:
  pushl $0
80105e09:	6a 00                	push   $0x0
  pushl $66
80105e0b:	6a 42                	push   $0x42
  jmp alltraps
80105e0d:	e9 18 f9 ff ff       	jmp    8010572a <alltraps>

80105e12 <vector67>:
.globl vector67
vector67:
  pushl $0
80105e12:	6a 00                	push   $0x0
  pushl $67
80105e14:	6a 43                	push   $0x43
  jmp alltraps
80105e16:	e9 0f f9 ff ff       	jmp    8010572a <alltraps>

80105e1b <vector68>:
.globl vector68
vector68:
  pushl $0
80105e1b:	6a 00                	push   $0x0
  pushl $68
80105e1d:	6a 44                	push   $0x44
  jmp alltraps
80105e1f:	e9 06 f9 ff ff       	jmp    8010572a <alltraps>

80105e24 <vector69>:
.globl vector69
vector69:
  pushl $0
80105e24:	6a 00                	push   $0x0
  pushl $69
80105e26:	6a 45                	push   $0x45
  jmp alltraps
80105e28:	e9 fd f8 ff ff       	jmp    8010572a <alltraps>

80105e2d <vector70>:
.globl vector70
vector70:
  pushl $0
80105e2d:	6a 00                	push   $0x0
  pushl $70
80105e2f:	6a 46                	push   $0x46
  jmp alltraps
80105e31:	e9 f4 f8 ff ff       	jmp    8010572a <alltraps>

80105e36 <vector71>:
.globl vector71
vector71:
  pushl $0
80105e36:	6a 00                	push   $0x0
  pushl $71
80105e38:	6a 47                	push   $0x47
  jmp alltraps
80105e3a:	e9 eb f8 ff ff       	jmp    8010572a <alltraps>

80105e3f <vector72>:
.globl vector72
vector72:
  pushl $0
80105e3f:	6a 00                	push   $0x0
  pushl $72
80105e41:	6a 48                	push   $0x48
  jmp alltraps
80105e43:	e9 e2 f8 ff ff       	jmp    8010572a <alltraps>

80105e48 <vector73>:
.globl vector73
vector73:
  pushl $0
80105e48:	6a 00                	push   $0x0
  pushl $73
80105e4a:	6a 49                	push   $0x49
  jmp alltraps
80105e4c:	e9 d9 f8 ff ff       	jmp    8010572a <alltraps>

80105e51 <vector74>:
.globl vector74
vector74:
  pushl $0
80105e51:	6a 00                	push   $0x0
  pushl $74
80105e53:	6a 4a                	push   $0x4a
  jmp alltraps
80105e55:	e9 d0 f8 ff ff       	jmp    8010572a <alltraps>

80105e5a <vector75>:
.globl vector75
vector75:
  pushl $0
80105e5a:	6a 00                	push   $0x0
  pushl $75
80105e5c:	6a 4b                	push   $0x4b
  jmp alltraps
80105e5e:	e9 c7 f8 ff ff       	jmp    8010572a <alltraps>

80105e63 <vector76>:
.globl vector76
vector76:
  pushl $0
80105e63:	6a 00                	push   $0x0
  pushl $76
80105e65:	6a 4c                	push   $0x4c
  jmp alltraps
80105e67:	e9 be f8 ff ff       	jmp    8010572a <alltraps>

80105e6c <vector77>:
.globl vector77
vector77:
  pushl $0
80105e6c:	6a 00                	push   $0x0
  pushl $77
80105e6e:	6a 4d                	push   $0x4d
  jmp alltraps
80105e70:	e9 b5 f8 ff ff       	jmp    8010572a <alltraps>

80105e75 <vector78>:
.globl vector78
vector78:
  pushl $0
80105e75:	6a 00                	push   $0x0
  pushl $78
80105e77:	6a 4e                	push   $0x4e
  jmp alltraps
80105e79:	e9 ac f8 ff ff       	jmp    8010572a <alltraps>

80105e7e <vector79>:
.globl vector79
vector79:
  pushl $0
80105e7e:	6a 00                	push   $0x0
  pushl $79
80105e80:	6a 4f                	push   $0x4f
  jmp alltraps
80105e82:	e9 a3 f8 ff ff       	jmp    8010572a <alltraps>

80105e87 <vector80>:
.globl vector80
vector80:
  pushl $0
80105e87:	6a 00                	push   $0x0
  pushl $80
80105e89:	6a 50                	push   $0x50
  jmp alltraps
80105e8b:	e9 9a f8 ff ff       	jmp    8010572a <alltraps>

80105e90 <vector81>:
.globl vector81
vector81:
  pushl $0
80105e90:	6a 00                	push   $0x0
  pushl $81
80105e92:	6a 51                	push   $0x51
  jmp alltraps
80105e94:	e9 91 f8 ff ff       	jmp    8010572a <alltraps>

80105e99 <vector82>:
.globl vector82
vector82:
  pushl $0
80105e99:	6a 00                	push   $0x0
  pushl $82
80105e9b:	6a 52                	push   $0x52
  jmp alltraps
80105e9d:	e9 88 f8 ff ff       	jmp    8010572a <alltraps>

80105ea2 <vector83>:
.globl vector83
vector83:
  pushl $0
80105ea2:	6a 00                	push   $0x0
  pushl $83
80105ea4:	6a 53                	push   $0x53
  jmp alltraps
80105ea6:	e9 7f f8 ff ff       	jmp    8010572a <alltraps>

80105eab <vector84>:
.globl vector84
vector84:
  pushl $0
80105eab:	6a 00                	push   $0x0
  pushl $84
80105ead:	6a 54                	push   $0x54
  jmp alltraps
80105eaf:	e9 76 f8 ff ff       	jmp    8010572a <alltraps>

80105eb4 <vector85>:
.globl vector85
vector85:
  pushl $0
80105eb4:	6a 00                	push   $0x0
  pushl $85
80105eb6:	6a 55                	push   $0x55
  jmp alltraps
80105eb8:	e9 6d f8 ff ff       	jmp    8010572a <alltraps>

80105ebd <vector86>:
.globl vector86
vector86:
  pushl $0
80105ebd:	6a 00                	push   $0x0
  pushl $86
80105ebf:	6a 56                	push   $0x56
  jmp alltraps
80105ec1:	e9 64 f8 ff ff       	jmp    8010572a <alltraps>

80105ec6 <vector87>:
.globl vector87
vector87:
  pushl $0
80105ec6:	6a 00                	push   $0x0
  pushl $87
80105ec8:	6a 57                	push   $0x57
  jmp alltraps
80105eca:	e9 5b f8 ff ff       	jmp    8010572a <alltraps>

80105ecf <vector88>:
.globl vector88
vector88:
  pushl $0
80105ecf:	6a 00                	push   $0x0
  pushl $88
80105ed1:	6a 58                	push   $0x58
  jmp alltraps
80105ed3:	e9 52 f8 ff ff       	jmp    8010572a <alltraps>

80105ed8 <vector89>:
.globl vector89
vector89:
  pushl $0
80105ed8:	6a 00                	push   $0x0
  pushl $89
80105eda:	6a 59                	push   $0x59
  jmp alltraps
80105edc:	e9 49 f8 ff ff       	jmp    8010572a <alltraps>

80105ee1 <vector90>:
.globl vector90
vector90:
  pushl $0
80105ee1:	6a 00                	push   $0x0
  pushl $90
80105ee3:	6a 5a                	push   $0x5a
  jmp alltraps
80105ee5:	e9 40 f8 ff ff       	jmp    8010572a <alltraps>

80105eea <vector91>:
.globl vector91
vector91:
  pushl $0
80105eea:	6a 00                	push   $0x0
  pushl $91
80105eec:	6a 5b                	push   $0x5b
  jmp alltraps
80105eee:	e9 37 f8 ff ff       	jmp    8010572a <alltraps>

80105ef3 <vector92>:
.globl vector92
vector92:
  pushl $0
80105ef3:	6a 00                	push   $0x0
  pushl $92
80105ef5:	6a 5c                	push   $0x5c
  jmp alltraps
80105ef7:	e9 2e f8 ff ff       	jmp    8010572a <alltraps>

80105efc <vector93>:
.globl vector93
vector93:
  pushl $0
80105efc:	6a 00                	push   $0x0
  pushl $93
80105efe:	6a 5d                	push   $0x5d
  jmp alltraps
80105f00:	e9 25 f8 ff ff       	jmp    8010572a <alltraps>

80105f05 <vector94>:
.globl vector94
vector94:
  pushl $0
80105f05:	6a 00                	push   $0x0
  pushl $94
80105f07:	6a 5e                	push   $0x5e
  jmp alltraps
80105f09:	e9 1c f8 ff ff       	jmp    8010572a <alltraps>

80105f0e <vector95>:
.globl vector95
vector95:
  pushl $0
80105f0e:	6a 00                	push   $0x0
  pushl $95
80105f10:	6a 5f                	push   $0x5f
  jmp alltraps
80105f12:	e9 13 f8 ff ff       	jmp    8010572a <alltraps>

80105f17 <vector96>:
.globl vector96
vector96:
  pushl $0
80105f17:	6a 00                	push   $0x0
  pushl $96
80105f19:	6a 60                	push   $0x60
  jmp alltraps
80105f1b:	e9 0a f8 ff ff       	jmp    8010572a <alltraps>

80105f20 <vector97>:
.globl vector97
vector97:
  pushl $0
80105f20:	6a 00                	push   $0x0
  pushl $97
80105f22:	6a 61                	push   $0x61
  jmp alltraps
80105f24:	e9 01 f8 ff ff       	jmp    8010572a <alltraps>

80105f29 <vector98>:
.globl vector98
vector98:
  pushl $0
80105f29:	6a 00                	push   $0x0
  pushl $98
80105f2b:	6a 62                	push   $0x62
  jmp alltraps
80105f2d:	e9 f8 f7 ff ff       	jmp    8010572a <alltraps>

80105f32 <vector99>:
.globl vector99
vector99:
  pushl $0
80105f32:	6a 00                	push   $0x0
  pushl $99
80105f34:	6a 63                	push   $0x63
  jmp alltraps
80105f36:	e9 ef f7 ff ff       	jmp    8010572a <alltraps>

80105f3b <vector100>:
.globl vector100
vector100:
  pushl $0
80105f3b:	6a 00                	push   $0x0
  pushl $100
80105f3d:	6a 64                	push   $0x64
  jmp alltraps
80105f3f:	e9 e6 f7 ff ff       	jmp    8010572a <alltraps>

80105f44 <vector101>:
.globl vector101
vector101:
  pushl $0
80105f44:	6a 00                	push   $0x0
  pushl $101
80105f46:	6a 65                	push   $0x65
  jmp alltraps
80105f48:	e9 dd f7 ff ff       	jmp    8010572a <alltraps>

80105f4d <vector102>:
.globl vector102
vector102:
  pushl $0
80105f4d:	6a 00                	push   $0x0
  pushl $102
80105f4f:	6a 66                	push   $0x66
  jmp alltraps
80105f51:	e9 d4 f7 ff ff       	jmp    8010572a <alltraps>

80105f56 <vector103>:
.globl vector103
vector103:
  pushl $0
80105f56:	6a 00                	push   $0x0
  pushl $103
80105f58:	6a 67                	push   $0x67
  jmp alltraps
80105f5a:	e9 cb f7 ff ff       	jmp    8010572a <alltraps>

80105f5f <vector104>:
.globl vector104
vector104:
  pushl $0
80105f5f:	6a 00                	push   $0x0
  pushl $104
80105f61:	6a 68                	push   $0x68
  jmp alltraps
80105f63:	e9 c2 f7 ff ff       	jmp    8010572a <alltraps>

80105f68 <vector105>:
.globl vector105
vector105:
  pushl $0
80105f68:	6a 00                	push   $0x0
  pushl $105
80105f6a:	6a 69                	push   $0x69
  jmp alltraps
80105f6c:	e9 b9 f7 ff ff       	jmp    8010572a <alltraps>

80105f71 <vector106>:
.globl vector106
vector106:
  pushl $0
80105f71:	6a 00                	push   $0x0
  pushl $106
80105f73:	6a 6a                	push   $0x6a
  jmp alltraps
80105f75:	e9 b0 f7 ff ff       	jmp    8010572a <alltraps>

80105f7a <vector107>:
.globl vector107
vector107:
  pushl $0
80105f7a:	6a 00                	push   $0x0
  pushl $107
80105f7c:	6a 6b                	push   $0x6b
  jmp alltraps
80105f7e:	e9 a7 f7 ff ff       	jmp    8010572a <alltraps>

80105f83 <vector108>:
.globl vector108
vector108:
  pushl $0
80105f83:	6a 00                	push   $0x0
  pushl $108
80105f85:	6a 6c                	push   $0x6c
  jmp alltraps
80105f87:	e9 9e f7 ff ff       	jmp    8010572a <alltraps>

80105f8c <vector109>:
.globl vector109
vector109:
  pushl $0
80105f8c:	6a 00                	push   $0x0
  pushl $109
80105f8e:	6a 6d                	push   $0x6d
  jmp alltraps
80105f90:	e9 95 f7 ff ff       	jmp    8010572a <alltraps>

80105f95 <vector110>:
.globl vector110
vector110:
  pushl $0
80105f95:	6a 00                	push   $0x0
  pushl $110
80105f97:	6a 6e                	push   $0x6e
  jmp alltraps
80105f99:	e9 8c f7 ff ff       	jmp    8010572a <alltraps>

80105f9e <vector111>:
.globl vector111
vector111:
  pushl $0
80105f9e:	6a 00                	push   $0x0
  pushl $111
80105fa0:	6a 6f                	push   $0x6f
  jmp alltraps
80105fa2:	e9 83 f7 ff ff       	jmp    8010572a <alltraps>

80105fa7 <vector112>:
.globl vector112
vector112:
  pushl $0
80105fa7:	6a 00                	push   $0x0
  pushl $112
80105fa9:	6a 70                	push   $0x70
  jmp alltraps
80105fab:	e9 7a f7 ff ff       	jmp    8010572a <alltraps>

80105fb0 <vector113>:
.globl vector113
vector113:
  pushl $0
80105fb0:	6a 00                	push   $0x0
  pushl $113
80105fb2:	6a 71                	push   $0x71
  jmp alltraps
80105fb4:	e9 71 f7 ff ff       	jmp    8010572a <alltraps>

80105fb9 <vector114>:
.globl vector114
vector114:
  pushl $0
80105fb9:	6a 00                	push   $0x0
  pushl $114
80105fbb:	6a 72                	push   $0x72
  jmp alltraps
80105fbd:	e9 68 f7 ff ff       	jmp    8010572a <alltraps>

80105fc2 <vector115>:
.globl vector115
vector115:
  pushl $0
80105fc2:	6a 00                	push   $0x0
  pushl $115
80105fc4:	6a 73                	push   $0x73
  jmp alltraps
80105fc6:	e9 5f f7 ff ff       	jmp    8010572a <alltraps>

80105fcb <vector116>:
.globl vector116
vector116:
  pushl $0
80105fcb:	6a 00                	push   $0x0
  pushl $116
80105fcd:	6a 74                	push   $0x74
  jmp alltraps
80105fcf:	e9 56 f7 ff ff       	jmp    8010572a <alltraps>

80105fd4 <vector117>:
.globl vector117
vector117:
  pushl $0
80105fd4:	6a 00                	push   $0x0
  pushl $117
80105fd6:	6a 75                	push   $0x75
  jmp alltraps
80105fd8:	e9 4d f7 ff ff       	jmp    8010572a <alltraps>

80105fdd <vector118>:
.globl vector118
vector118:
  pushl $0
80105fdd:	6a 00                	push   $0x0
  pushl $118
80105fdf:	6a 76                	push   $0x76
  jmp alltraps
80105fe1:	e9 44 f7 ff ff       	jmp    8010572a <alltraps>

80105fe6 <vector119>:
.globl vector119
vector119:
  pushl $0
80105fe6:	6a 00                	push   $0x0
  pushl $119
80105fe8:	6a 77                	push   $0x77
  jmp alltraps
80105fea:	e9 3b f7 ff ff       	jmp    8010572a <alltraps>

80105fef <vector120>:
.globl vector120
vector120:
  pushl $0
80105fef:	6a 00                	push   $0x0
  pushl $120
80105ff1:	6a 78                	push   $0x78
  jmp alltraps
80105ff3:	e9 32 f7 ff ff       	jmp    8010572a <alltraps>

80105ff8 <vector121>:
.globl vector121
vector121:
  pushl $0
80105ff8:	6a 00                	push   $0x0
  pushl $121
80105ffa:	6a 79                	push   $0x79
  jmp alltraps
80105ffc:	e9 29 f7 ff ff       	jmp    8010572a <alltraps>

80106001 <vector122>:
.globl vector122
vector122:
  pushl $0
80106001:	6a 00                	push   $0x0
  pushl $122
80106003:	6a 7a                	push   $0x7a
  jmp alltraps
80106005:	e9 20 f7 ff ff       	jmp    8010572a <alltraps>

8010600a <vector123>:
.globl vector123
vector123:
  pushl $0
8010600a:	6a 00                	push   $0x0
  pushl $123
8010600c:	6a 7b                	push   $0x7b
  jmp alltraps
8010600e:	e9 17 f7 ff ff       	jmp    8010572a <alltraps>

80106013 <vector124>:
.globl vector124
vector124:
  pushl $0
80106013:	6a 00                	push   $0x0
  pushl $124
80106015:	6a 7c                	push   $0x7c
  jmp alltraps
80106017:	e9 0e f7 ff ff       	jmp    8010572a <alltraps>

8010601c <vector125>:
.globl vector125
vector125:
  pushl $0
8010601c:	6a 00                	push   $0x0
  pushl $125
8010601e:	6a 7d                	push   $0x7d
  jmp alltraps
80106020:	e9 05 f7 ff ff       	jmp    8010572a <alltraps>

80106025 <vector126>:
.globl vector126
vector126:
  pushl $0
80106025:	6a 00                	push   $0x0
  pushl $126
80106027:	6a 7e                	push   $0x7e
  jmp alltraps
80106029:	e9 fc f6 ff ff       	jmp    8010572a <alltraps>

8010602e <vector127>:
.globl vector127
vector127:
  pushl $0
8010602e:	6a 00                	push   $0x0
  pushl $127
80106030:	6a 7f                	push   $0x7f
  jmp alltraps
80106032:	e9 f3 f6 ff ff       	jmp    8010572a <alltraps>

80106037 <vector128>:
.globl vector128
vector128:
  pushl $0
80106037:	6a 00                	push   $0x0
  pushl $128
80106039:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010603e:	e9 e7 f6 ff ff       	jmp    8010572a <alltraps>

80106043 <vector129>:
.globl vector129
vector129:
  pushl $0
80106043:	6a 00                	push   $0x0
  pushl $129
80106045:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010604a:	e9 db f6 ff ff       	jmp    8010572a <alltraps>

8010604f <vector130>:
.globl vector130
vector130:
  pushl $0
8010604f:	6a 00                	push   $0x0
  pushl $130
80106051:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106056:	e9 cf f6 ff ff       	jmp    8010572a <alltraps>

8010605b <vector131>:
.globl vector131
vector131:
  pushl $0
8010605b:	6a 00                	push   $0x0
  pushl $131
8010605d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106062:	e9 c3 f6 ff ff       	jmp    8010572a <alltraps>

80106067 <vector132>:
.globl vector132
vector132:
  pushl $0
80106067:	6a 00                	push   $0x0
  pushl $132
80106069:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010606e:	e9 b7 f6 ff ff       	jmp    8010572a <alltraps>

80106073 <vector133>:
.globl vector133
vector133:
  pushl $0
80106073:	6a 00                	push   $0x0
  pushl $133
80106075:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010607a:	e9 ab f6 ff ff       	jmp    8010572a <alltraps>

8010607f <vector134>:
.globl vector134
vector134:
  pushl $0
8010607f:	6a 00                	push   $0x0
  pushl $134
80106081:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106086:	e9 9f f6 ff ff       	jmp    8010572a <alltraps>

8010608b <vector135>:
.globl vector135
vector135:
  pushl $0
8010608b:	6a 00                	push   $0x0
  pushl $135
8010608d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106092:	e9 93 f6 ff ff       	jmp    8010572a <alltraps>

80106097 <vector136>:
.globl vector136
vector136:
  pushl $0
80106097:	6a 00                	push   $0x0
  pushl $136
80106099:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010609e:	e9 87 f6 ff ff       	jmp    8010572a <alltraps>

801060a3 <vector137>:
.globl vector137
vector137:
  pushl $0
801060a3:	6a 00                	push   $0x0
  pushl $137
801060a5:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801060aa:	e9 7b f6 ff ff       	jmp    8010572a <alltraps>

801060af <vector138>:
.globl vector138
vector138:
  pushl $0
801060af:	6a 00                	push   $0x0
  pushl $138
801060b1:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801060b6:	e9 6f f6 ff ff       	jmp    8010572a <alltraps>

801060bb <vector139>:
.globl vector139
vector139:
  pushl $0
801060bb:	6a 00                	push   $0x0
  pushl $139
801060bd:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801060c2:	e9 63 f6 ff ff       	jmp    8010572a <alltraps>

801060c7 <vector140>:
.globl vector140
vector140:
  pushl $0
801060c7:	6a 00                	push   $0x0
  pushl $140
801060c9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801060ce:	e9 57 f6 ff ff       	jmp    8010572a <alltraps>

801060d3 <vector141>:
.globl vector141
vector141:
  pushl $0
801060d3:	6a 00                	push   $0x0
  pushl $141
801060d5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801060da:	e9 4b f6 ff ff       	jmp    8010572a <alltraps>

801060df <vector142>:
.globl vector142
vector142:
  pushl $0
801060df:	6a 00                	push   $0x0
  pushl $142
801060e1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801060e6:	e9 3f f6 ff ff       	jmp    8010572a <alltraps>

801060eb <vector143>:
.globl vector143
vector143:
  pushl $0
801060eb:	6a 00                	push   $0x0
  pushl $143
801060ed:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801060f2:	e9 33 f6 ff ff       	jmp    8010572a <alltraps>

801060f7 <vector144>:
.globl vector144
vector144:
  pushl $0
801060f7:	6a 00                	push   $0x0
  pushl $144
801060f9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801060fe:	e9 27 f6 ff ff       	jmp    8010572a <alltraps>

80106103 <vector145>:
.globl vector145
vector145:
  pushl $0
80106103:	6a 00                	push   $0x0
  pushl $145
80106105:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010610a:	e9 1b f6 ff ff       	jmp    8010572a <alltraps>

8010610f <vector146>:
.globl vector146
vector146:
  pushl $0
8010610f:	6a 00                	push   $0x0
  pushl $146
80106111:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106116:	e9 0f f6 ff ff       	jmp    8010572a <alltraps>

8010611b <vector147>:
.globl vector147
vector147:
  pushl $0
8010611b:	6a 00                	push   $0x0
  pushl $147
8010611d:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106122:	e9 03 f6 ff ff       	jmp    8010572a <alltraps>

80106127 <vector148>:
.globl vector148
vector148:
  pushl $0
80106127:	6a 00                	push   $0x0
  pushl $148
80106129:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010612e:	e9 f7 f5 ff ff       	jmp    8010572a <alltraps>

80106133 <vector149>:
.globl vector149
vector149:
  pushl $0
80106133:	6a 00                	push   $0x0
  pushl $149
80106135:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010613a:	e9 eb f5 ff ff       	jmp    8010572a <alltraps>

8010613f <vector150>:
.globl vector150
vector150:
  pushl $0
8010613f:	6a 00                	push   $0x0
  pushl $150
80106141:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106146:	e9 df f5 ff ff       	jmp    8010572a <alltraps>

8010614b <vector151>:
.globl vector151
vector151:
  pushl $0
8010614b:	6a 00                	push   $0x0
  pushl $151
8010614d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106152:	e9 d3 f5 ff ff       	jmp    8010572a <alltraps>

80106157 <vector152>:
.globl vector152
vector152:
  pushl $0
80106157:	6a 00                	push   $0x0
  pushl $152
80106159:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010615e:	e9 c7 f5 ff ff       	jmp    8010572a <alltraps>

80106163 <vector153>:
.globl vector153
vector153:
  pushl $0
80106163:	6a 00                	push   $0x0
  pushl $153
80106165:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010616a:	e9 bb f5 ff ff       	jmp    8010572a <alltraps>

8010616f <vector154>:
.globl vector154
vector154:
  pushl $0
8010616f:	6a 00                	push   $0x0
  pushl $154
80106171:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106176:	e9 af f5 ff ff       	jmp    8010572a <alltraps>

8010617b <vector155>:
.globl vector155
vector155:
  pushl $0
8010617b:	6a 00                	push   $0x0
  pushl $155
8010617d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106182:	e9 a3 f5 ff ff       	jmp    8010572a <alltraps>

80106187 <vector156>:
.globl vector156
vector156:
  pushl $0
80106187:	6a 00                	push   $0x0
  pushl $156
80106189:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010618e:	e9 97 f5 ff ff       	jmp    8010572a <alltraps>

80106193 <vector157>:
.globl vector157
vector157:
  pushl $0
80106193:	6a 00                	push   $0x0
  pushl $157
80106195:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010619a:	e9 8b f5 ff ff       	jmp    8010572a <alltraps>

8010619f <vector158>:
.globl vector158
vector158:
  pushl $0
8010619f:	6a 00                	push   $0x0
  pushl $158
801061a1:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801061a6:	e9 7f f5 ff ff       	jmp    8010572a <alltraps>

801061ab <vector159>:
.globl vector159
vector159:
  pushl $0
801061ab:	6a 00                	push   $0x0
  pushl $159
801061ad:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801061b2:	e9 73 f5 ff ff       	jmp    8010572a <alltraps>

801061b7 <vector160>:
.globl vector160
vector160:
  pushl $0
801061b7:	6a 00                	push   $0x0
  pushl $160
801061b9:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801061be:	e9 67 f5 ff ff       	jmp    8010572a <alltraps>

801061c3 <vector161>:
.globl vector161
vector161:
  pushl $0
801061c3:	6a 00                	push   $0x0
  pushl $161
801061c5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801061ca:	e9 5b f5 ff ff       	jmp    8010572a <alltraps>

801061cf <vector162>:
.globl vector162
vector162:
  pushl $0
801061cf:	6a 00                	push   $0x0
  pushl $162
801061d1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801061d6:	e9 4f f5 ff ff       	jmp    8010572a <alltraps>

801061db <vector163>:
.globl vector163
vector163:
  pushl $0
801061db:	6a 00                	push   $0x0
  pushl $163
801061dd:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801061e2:	e9 43 f5 ff ff       	jmp    8010572a <alltraps>

801061e7 <vector164>:
.globl vector164
vector164:
  pushl $0
801061e7:	6a 00                	push   $0x0
  pushl $164
801061e9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801061ee:	e9 37 f5 ff ff       	jmp    8010572a <alltraps>

801061f3 <vector165>:
.globl vector165
vector165:
  pushl $0
801061f3:	6a 00                	push   $0x0
  pushl $165
801061f5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801061fa:	e9 2b f5 ff ff       	jmp    8010572a <alltraps>

801061ff <vector166>:
.globl vector166
vector166:
  pushl $0
801061ff:	6a 00                	push   $0x0
  pushl $166
80106201:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106206:	e9 1f f5 ff ff       	jmp    8010572a <alltraps>

8010620b <vector167>:
.globl vector167
vector167:
  pushl $0
8010620b:	6a 00                	push   $0x0
  pushl $167
8010620d:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106212:	e9 13 f5 ff ff       	jmp    8010572a <alltraps>

80106217 <vector168>:
.globl vector168
vector168:
  pushl $0
80106217:	6a 00                	push   $0x0
  pushl $168
80106219:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010621e:	e9 07 f5 ff ff       	jmp    8010572a <alltraps>

80106223 <vector169>:
.globl vector169
vector169:
  pushl $0
80106223:	6a 00                	push   $0x0
  pushl $169
80106225:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010622a:	e9 fb f4 ff ff       	jmp    8010572a <alltraps>

8010622f <vector170>:
.globl vector170
vector170:
  pushl $0
8010622f:	6a 00                	push   $0x0
  pushl $170
80106231:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106236:	e9 ef f4 ff ff       	jmp    8010572a <alltraps>

8010623b <vector171>:
.globl vector171
vector171:
  pushl $0
8010623b:	6a 00                	push   $0x0
  pushl $171
8010623d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106242:	e9 e3 f4 ff ff       	jmp    8010572a <alltraps>

80106247 <vector172>:
.globl vector172
vector172:
  pushl $0
80106247:	6a 00                	push   $0x0
  pushl $172
80106249:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010624e:	e9 d7 f4 ff ff       	jmp    8010572a <alltraps>

80106253 <vector173>:
.globl vector173
vector173:
  pushl $0
80106253:	6a 00                	push   $0x0
  pushl $173
80106255:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010625a:	e9 cb f4 ff ff       	jmp    8010572a <alltraps>

8010625f <vector174>:
.globl vector174
vector174:
  pushl $0
8010625f:	6a 00                	push   $0x0
  pushl $174
80106261:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106266:	e9 bf f4 ff ff       	jmp    8010572a <alltraps>

8010626b <vector175>:
.globl vector175
vector175:
  pushl $0
8010626b:	6a 00                	push   $0x0
  pushl $175
8010626d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106272:	e9 b3 f4 ff ff       	jmp    8010572a <alltraps>

80106277 <vector176>:
.globl vector176
vector176:
  pushl $0
80106277:	6a 00                	push   $0x0
  pushl $176
80106279:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010627e:	e9 a7 f4 ff ff       	jmp    8010572a <alltraps>

80106283 <vector177>:
.globl vector177
vector177:
  pushl $0
80106283:	6a 00                	push   $0x0
  pushl $177
80106285:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010628a:	e9 9b f4 ff ff       	jmp    8010572a <alltraps>

8010628f <vector178>:
.globl vector178
vector178:
  pushl $0
8010628f:	6a 00                	push   $0x0
  pushl $178
80106291:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106296:	e9 8f f4 ff ff       	jmp    8010572a <alltraps>

8010629b <vector179>:
.globl vector179
vector179:
  pushl $0
8010629b:	6a 00                	push   $0x0
  pushl $179
8010629d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801062a2:	e9 83 f4 ff ff       	jmp    8010572a <alltraps>

801062a7 <vector180>:
.globl vector180
vector180:
  pushl $0
801062a7:	6a 00                	push   $0x0
  pushl $180
801062a9:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801062ae:	e9 77 f4 ff ff       	jmp    8010572a <alltraps>

801062b3 <vector181>:
.globl vector181
vector181:
  pushl $0
801062b3:	6a 00                	push   $0x0
  pushl $181
801062b5:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801062ba:	e9 6b f4 ff ff       	jmp    8010572a <alltraps>

801062bf <vector182>:
.globl vector182
vector182:
  pushl $0
801062bf:	6a 00                	push   $0x0
  pushl $182
801062c1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801062c6:	e9 5f f4 ff ff       	jmp    8010572a <alltraps>

801062cb <vector183>:
.globl vector183
vector183:
  pushl $0
801062cb:	6a 00                	push   $0x0
  pushl $183
801062cd:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801062d2:	e9 53 f4 ff ff       	jmp    8010572a <alltraps>

801062d7 <vector184>:
.globl vector184
vector184:
  pushl $0
801062d7:	6a 00                	push   $0x0
  pushl $184
801062d9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801062de:	e9 47 f4 ff ff       	jmp    8010572a <alltraps>

801062e3 <vector185>:
.globl vector185
vector185:
  pushl $0
801062e3:	6a 00                	push   $0x0
  pushl $185
801062e5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801062ea:	e9 3b f4 ff ff       	jmp    8010572a <alltraps>

801062ef <vector186>:
.globl vector186
vector186:
  pushl $0
801062ef:	6a 00                	push   $0x0
  pushl $186
801062f1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801062f6:	e9 2f f4 ff ff       	jmp    8010572a <alltraps>

801062fb <vector187>:
.globl vector187
vector187:
  pushl $0
801062fb:	6a 00                	push   $0x0
  pushl $187
801062fd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106302:	e9 23 f4 ff ff       	jmp    8010572a <alltraps>

80106307 <vector188>:
.globl vector188
vector188:
  pushl $0
80106307:	6a 00                	push   $0x0
  pushl $188
80106309:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010630e:	e9 17 f4 ff ff       	jmp    8010572a <alltraps>

80106313 <vector189>:
.globl vector189
vector189:
  pushl $0
80106313:	6a 00                	push   $0x0
  pushl $189
80106315:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010631a:	e9 0b f4 ff ff       	jmp    8010572a <alltraps>

8010631f <vector190>:
.globl vector190
vector190:
  pushl $0
8010631f:	6a 00                	push   $0x0
  pushl $190
80106321:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106326:	e9 ff f3 ff ff       	jmp    8010572a <alltraps>

8010632b <vector191>:
.globl vector191
vector191:
  pushl $0
8010632b:	6a 00                	push   $0x0
  pushl $191
8010632d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106332:	e9 f3 f3 ff ff       	jmp    8010572a <alltraps>

80106337 <vector192>:
.globl vector192
vector192:
  pushl $0
80106337:	6a 00                	push   $0x0
  pushl $192
80106339:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010633e:	e9 e7 f3 ff ff       	jmp    8010572a <alltraps>

80106343 <vector193>:
.globl vector193
vector193:
  pushl $0
80106343:	6a 00                	push   $0x0
  pushl $193
80106345:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010634a:	e9 db f3 ff ff       	jmp    8010572a <alltraps>

8010634f <vector194>:
.globl vector194
vector194:
  pushl $0
8010634f:	6a 00                	push   $0x0
  pushl $194
80106351:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106356:	e9 cf f3 ff ff       	jmp    8010572a <alltraps>

8010635b <vector195>:
.globl vector195
vector195:
  pushl $0
8010635b:	6a 00                	push   $0x0
  pushl $195
8010635d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106362:	e9 c3 f3 ff ff       	jmp    8010572a <alltraps>

80106367 <vector196>:
.globl vector196
vector196:
  pushl $0
80106367:	6a 00                	push   $0x0
  pushl $196
80106369:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010636e:	e9 b7 f3 ff ff       	jmp    8010572a <alltraps>

80106373 <vector197>:
.globl vector197
vector197:
  pushl $0
80106373:	6a 00                	push   $0x0
  pushl $197
80106375:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010637a:	e9 ab f3 ff ff       	jmp    8010572a <alltraps>

8010637f <vector198>:
.globl vector198
vector198:
  pushl $0
8010637f:	6a 00                	push   $0x0
  pushl $198
80106381:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106386:	e9 9f f3 ff ff       	jmp    8010572a <alltraps>

8010638b <vector199>:
.globl vector199
vector199:
  pushl $0
8010638b:	6a 00                	push   $0x0
  pushl $199
8010638d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106392:	e9 93 f3 ff ff       	jmp    8010572a <alltraps>

80106397 <vector200>:
.globl vector200
vector200:
  pushl $0
80106397:	6a 00                	push   $0x0
  pushl $200
80106399:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010639e:	e9 87 f3 ff ff       	jmp    8010572a <alltraps>

801063a3 <vector201>:
.globl vector201
vector201:
  pushl $0
801063a3:	6a 00                	push   $0x0
  pushl $201
801063a5:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801063aa:	e9 7b f3 ff ff       	jmp    8010572a <alltraps>

801063af <vector202>:
.globl vector202
vector202:
  pushl $0
801063af:	6a 00                	push   $0x0
  pushl $202
801063b1:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801063b6:	e9 6f f3 ff ff       	jmp    8010572a <alltraps>

801063bb <vector203>:
.globl vector203
vector203:
  pushl $0
801063bb:	6a 00                	push   $0x0
  pushl $203
801063bd:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801063c2:	e9 63 f3 ff ff       	jmp    8010572a <alltraps>

801063c7 <vector204>:
.globl vector204
vector204:
  pushl $0
801063c7:	6a 00                	push   $0x0
  pushl $204
801063c9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801063ce:	e9 57 f3 ff ff       	jmp    8010572a <alltraps>

801063d3 <vector205>:
.globl vector205
vector205:
  pushl $0
801063d3:	6a 00                	push   $0x0
  pushl $205
801063d5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801063da:	e9 4b f3 ff ff       	jmp    8010572a <alltraps>

801063df <vector206>:
.globl vector206
vector206:
  pushl $0
801063df:	6a 00                	push   $0x0
  pushl $206
801063e1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801063e6:	e9 3f f3 ff ff       	jmp    8010572a <alltraps>

801063eb <vector207>:
.globl vector207
vector207:
  pushl $0
801063eb:	6a 00                	push   $0x0
  pushl $207
801063ed:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801063f2:	e9 33 f3 ff ff       	jmp    8010572a <alltraps>

801063f7 <vector208>:
.globl vector208
vector208:
  pushl $0
801063f7:	6a 00                	push   $0x0
  pushl $208
801063f9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801063fe:	e9 27 f3 ff ff       	jmp    8010572a <alltraps>

80106403 <vector209>:
.globl vector209
vector209:
  pushl $0
80106403:	6a 00                	push   $0x0
  pushl $209
80106405:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010640a:	e9 1b f3 ff ff       	jmp    8010572a <alltraps>

8010640f <vector210>:
.globl vector210
vector210:
  pushl $0
8010640f:	6a 00                	push   $0x0
  pushl $210
80106411:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106416:	e9 0f f3 ff ff       	jmp    8010572a <alltraps>

8010641b <vector211>:
.globl vector211
vector211:
  pushl $0
8010641b:	6a 00                	push   $0x0
  pushl $211
8010641d:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106422:	e9 03 f3 ff ff       	jmp    8010572a <alltraps>

80106427 <vector212>:
.globl vector212
vector212:
  pushl $0
80106427:	6a 00                	push   $0x0
  pushl $212
80106429:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010642e:	e9 f7 f2 ff ff       	jmp    8010572a <alltraps>

80106433 <vector213>:
.globl vector213
vector213:
  pushl $0
80106433:	6a 00                	push   $0x0
  pushl $213
80106435:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010643a:	e9 eb f2 ff ff       	jmp    8010572a <alltraps>

8010643f <vector214>:
.globl vector214
vector214:
  pushl $0
8010643f:	6a 00                	push   $0x0
  pushl $214
80106441:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106446:	e9 df f2 ff ff       	jmp    8010572a <alltraps>

8010644b <vector215>:
.globl vector215
vector215:
  pushl $0
8010644b:	6a 00                	push   $0x0
  pushl $215
8010644d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106452:	e9 d3 f2 ff ff       	jmp    8010572a <alltraps>

80106457 <vector216>:
.globl vector216
vector216:
  pushl $0
80106457:	6a 00                	push   $0x0
  pushl $216
80106459:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010645e:	e9 c7 f2 ff ff       	jmp    8010572a <alltraps>

80106463 <vector217>:
.globl vector217
vector217:
  pushl $0
80106463:	6a 00                	push   $0x0
  pushl $217
80106465:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010646a:	e9 bb f2 ff ff       	jmp    8010572a <alltraps>

8010646f <vector218>:
.globl vector218
vector218:
  pushl $0
8010646f:	6a 00                	push   $0x0
  pushl $218
80106471:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106476:	e9 af f2 ff ff       	jmp    8010572a <alltraps>

8010647b <vector219>:
.globl vector219
vector219:
  pushl $0
8010647b:	6a 00                	push   $0x0
  pushl $219
8010647d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106482:	e9 a3 f2 ff ff       	jmp    8010572a <alltraps>

80106487 <vector220>:
.globl vector220
vector220:
  pushl $0
80106487:	6a 00                	push   $0x0
  pushl $220
80106489:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010648e:	e9 97 f2 ff ff       	jmp    8010572a <alltraps>

80106493 <vector221>:
.globl vector221
vector221:
  pushl $0
80106493:	6a 00                	push   $0x0
  pushl $221
80106495:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010649a:	e9 8b f2 ff ff       	jmp    8010572a <alltraps>

8010649f <vector222>:
.globl vector222
vector222:
  pushl $0
8010649f:	6a 00                	push   $0x0
  pushl $222
801064a1:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801064a6:	e9 7f f2 ff ff       	jmp    8010572a <alltraps>

801064ab <vector223>:
.globl vector223
vector223:
  pushl $0
801064ab:	6a 00                	push   $0x0
  pushl $223
801064ad:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801064b2:	e9 73 f2 ff ff       	jmp    8010572a <alltraps>

801064b7 <vector224>:
.globl vector224
vector224:
  pushl $0
801064b7:	6a 00                	push   $0x0
  pushl $224
801064b9:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801064be:	e9 67 f2 ff ff       	jmp    8010572a <alltraps>

801064c3 <vector225>:
.globl vector225
vector225:
  pushl $0
801064c3:	6a 00                	push   $0x0
  pushl $225
801064c5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801064ca:	e9 5b f2 ff ff       	jmp    8010572a <alltraps>

801064cf <vector226>:
.globl vector226
vector226:
  pushl $0
801064cf:	6a 00                	push   $0x0
  pushl $226
801064d1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801064d6:	e9 4f f2 ff ff       	jmp    8010572a <alltraps>

801064db <vector227>:
.globl vector227
vector227:
  pushl $0
801064db:	6a 00                	push   $0x0
  pushl $227
801064dd:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801064e2:	e9 43 f2 ff ff       	jmp    8010572a <alltraps>

801064e7 <vector228>:
.globl vector228
vector228:
  pushl $0
801064e7:	6a 00                	push   $0x0
  pushl $228
801064e9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801064ee:	e9 37 f2 ff ff       	jmp    8010572a <alltraps>

801064f3 <vector229>:
.globl vector229
vector229:
  pushl $0
801064f3:	6a 00                	push   $0x0
  pushl $229
801064f5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801064fa:	e9 2b f2 ff ff       	jmp    8010572a <alltraps>

801064ff <vector230>:
.globl vector230
vector230:
  pushl $0
801064ff:	6a 00                	push   $0x0
  pushl $230
80106501:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106506:	e9 1f f2 ff ff       	jmp    8010572a <alltraps>

8010650b <vector231>:
.globl vector231
vector231:
  pushl $0
8010650b:	6a 00                	push   $0x0
  pushl $231
8010650d:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106512:	e9 13 f2 ff ff       	jmp    8010572a <alltraps>

80106517 <vector232>:
.globl vector232
vector232:
  pushl $0
80106517:	6a 00                	push   $0x0
  pushl $232
80106519:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010651e:	e9 07 f2 ff ff       	jmp    8010572a <alltraps>

80106523 <vector233>:
.globl vector233
vector233:
  pushl $0
80106523:	6a 00                	push   $0x0
  pushl $233
80106525:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010652a:	e9 fb f1 ff ff       	jmp    8010572a <alltraps>

8010652f <vector234>:
.globl vector234
vector234:
  pushl $0
8010652f:	6a 00                	push   $0x0
  pushl $234
80106531:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106536:	e9 ef f1 ff ff       	jmp    8010572a <alltraps>

8010653b <vector235>:
.globl vector235
vector235:
  pushl $0
8010653b:	6a 00                	push   $0x0
  pushl $235
8010653d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106542:	e9 e3 f1 ff ff       	jmp    8010572a <alltraps>

80106547 <vector236>:
.globl vector236
vector236:
  pushl $0
80106547:	6a 00                	push   $0x0
  pushl $236
80106549:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010654e:	e9 d7 f1 ff ff       	jmp    8010572a <alltraps>

80106553 <vector237>:
.globl vector237
vector237:
  pushl $0
80106553:	6a 00                	push   $0x0
  pushl $237
80106555:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010655a:	e9 cb f1 ff ff       	jmp    8010572a <alltraps>

8010655f <vector238>:
.globl vector238
vector238:
  pushl $0
8010655f:	6a 00                	push   $0x0
  pushl $238
80106561:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106566:	e9 bf f1 ff ff       	jmp    8010572a <alltraps>

8010656b <vector239>:
.globl vector239
vector239:
  pushl $0
8010656b:	6a 00                	push   $0x0
  pushl $239
8010656d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106572:	e9 b3 f1 ff ff       	jmp    8010572a <alltraps>

80106577 <vector240>:
.globl vector240
vector240:
  pushl $0
80106577:	6a 00                	push   $0x0
  pushl $240
80106579:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010657e:	e9 a7 f1 ff ff       	jmp    8010572a <alltraps>

80106583 <vector241>:
.globl vector241
vector241:
  pushl $0
80106583:	6a 00                	push   $0x0
  pushl $241
80106585:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010658a:	e9 9b f1 ff ff       	jmp    8010572a <alltraps>

8010658f <vector242>:
.globl vector242
vector242:
  pushl $0
8010658f:	6a 00                	push   $0x0
  pushl $242
80106591:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106596:	e9 8f f1 ff ff       	jmp    8010572a <alltraps>

8010659b <vector243>:
.globl vector243
vector243:
  pushl $0
8010659b:	6a 00                	push   $0x0
  pushl $243
8010659d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801065a2:	e9 83 f1 ff ff       	jmp    8010572a <alltraps>

801065a7 <vector244>:
.globl vector244
vector244:
  pushl $0
801065a7:	6a 00                	push   $0x0
  pushl $244
801065a9:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801065ae:	e9 77 f1 ff ff       	jmp    8010572a <alltraps>

801065b3 <vector245>:
.globl vector245
vector245:
  pushl $0
801065b3:	6a 00                	push   $0x0
  pushl $245
801065b5:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801065ba:	e9 6b f1 ff ff       	jmp    8010572a <alltraps>

801065bf <vector246>:
.globl vector246
vector246:
  pushl $0
801065bf:	6a 00                	push   $0x0
  pushl $246
801065c1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801065c6:	e9 5f f1 ff ff       	jmp    8010572a <alltraps>

801065cb <vector247>:
.globl vector247
vector247:
  pushl $0
801065cb:	6a 00                	push   $0x0
  pushl $247
801065cd:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801065d2:	e9 53 f1 ff ff       	jmp    8010572a <alltraps>

801065d7 <vector248>:
.globl vector248
vector248:
  pushl $0
801065d7:	6a 00                	push   $0x0
  pushl $248
801065d9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801065de:	e9 47 f1 ff ff       	jmp    8010572a <alltraps>

801065e3 <vector249>:
.globl vector249
vector249:
  pushl $0
801065e3:	6a 00                	push   $0x0
  pushl $249
801065e5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801065ea:	e9 3b f1 ff ff       	jmp    8010572a <alltraps>

801065ef <vector250>:
.globl vector250
vector250:
  pushl $0
801065ef:	6a 00                	push   $0x0
  pushl $250
801065f1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801065f6:	e9 2f f1 ff ff       	jmp    8010572a <alltraps>

801065fb <vector251>:
.globl vector251
vector251:
  pushl $0
801065fb:	6a 00                	push   $0x0
  pushl $251
801065fd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106602:	e9 23 f1 ff ff       	jmp    8010572a <alltraps>

80106607 <vector252>:
.globl vector252
vector252:
  pushl $0
80106607:	6a 00                	push   $0x0
  pushl $252
80106609:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010660e:	e9 17 f1 ff ff       	jmp    8010572a <alltraps>

80106613 <vector253>:
.globl vector253
vector253:
  pushl $0
80106613:	6a 00                	push   $0x0
  pushl $253
80106615:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010661a:	e9 0b f1 ff ff       	jmp    8010572a <alltraps>

8010661f <vector254>:
.globl vector254
vector254:
  pushl $0
8010661f:	6a 00                	push   $0x0
  pushl $254
80106621:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106626:	e9 ff f0 ff ff       	jmp    8010572a <alltraps>

8010662b <vector255>:
.globl vector255
vector255:
  pushl $0
8010662b:	6a 00                	push   $0x0
  pushl $255
8010662d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106632:	e9 f3 f0 ff ff       	jmp    8010572a <alltraps>
80106637:	66 90                	xchg   %ax,%ax
80106639:	66 90                	xchg   %ax,%ax
8010663b:	66 90                	xchg   %ax,%ax
8010663d:	66 90                	xchg   %ax,%ax
8010663f:	90                   	nop

80106640 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106640:	55                   	push   %ebp
80106641:	89 e5                	mov    %esp,%ebp
80106643:	57                   	push   %edi
80106644:	56                   	push   %esi
80106645:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106647:	c1 ea 16             	shr    $0x16,%edx
{
8010664a:	53                   	push   %ebx
  pde = &pgdir[PDX(va)];
8010664b:	8d 3c 90             	lea    (%eax,%edx,4),%edi
{
8010664e:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80106651:	8b 1f                	mov    (%edi),%ebx
80106653:	f6 c3 01             	test   $0x1,%bl
80106656:	74 28                	je     80106680 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106658:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
8010665e:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106664:	89 f0                	mov    %esi,%eax
}
80106666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
80106669:	c1 e8 0a             	shr    $0xa,%eax
8010666c:	25 fc 0f 00 00       	and    $0xffc,%eax
80106671:	01 d8                	add    %ebx,%eax
}
80106673:	5b                   	pop    %ebx
80106674:	5e                   	pop    %esi
80106675:	5f                   	pop    %edi
80106676:	5d                   	pop    %ebp
80106677:	c3                   	ret
80106678:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010667f:	00 
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106680:	85 c9                	test   %ecx,%ecx
80106682:	74 2c                	je     801066b0 <walkpgdir+0x70>
80106684:	e8 d7 bf ff ff       	call   80102660 <kalloc>
80106689:	89 c3                	mov    %eax,%ebx
8010668b:	85 c0                	test   %eax,%eax
8010668d:	74 21                	je     801066b0 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
8010668f:	83 ec 04             	sub    $0x4,%esp
80106692:	68 00 10 00 00       	push   $0x1000
80106697:	6a 00                	push   $0x0
80106699:	50                   	push   %eax
8010669a:	e8 11 df ff ff       	call   801045b0 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010669f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801066a5:	83 c4 10             	add    $0x10,%esp
801066a8:	83 c8 07             	or     $0x7,%eax
801066ab:	89 07                	mov    %eax,(%edi)
801066ad:	eb b5                	jmp    80106664 <walkpgdir+0x24>
801066af:	90                   	nop
}
801066b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
801066b3:	31 c0                	xor    %eax,%eax
}
801066b5:	5b                   	pop    %ebx
801066b6:	5e                   	pop    %esi
801066b7:	5f                   	pop    %edi
801066b8:	5d                   	pop    %ebp
801066b9:	c3                   	ret
801066ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801066c0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801066c0:	55                   	push   %ebp
801066c1:	89 e5                	mov    %esp,%ebp
801066c3:	57                   	push   %edi
801066c4:	89 c7                	mov    %eax,%edi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801066c6:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
{
801066ca:	56                   	push   %esi
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801066cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  a = (char*)PGROUNDDOWN((uint)va);
801066d0:	89 d6                	mov    %edx,%esi
{
801066d2:	53                   	push   %ebx
  a = (char*)PGROUNDDOWN((uint)va);
801066d3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
{
801066d9:	83 ec 1c             	sub    $0x1c,%esp
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801066dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
801066df:	8b 45 08             	mov    0x8(%ebp),%eax
801066e2:	29 f0                	sub    %esi,%eax
801066e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801066e7:	eb 1f                	jmp    80106708 <mappages+0x48>
801066e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
801066f0:	f6 00 01             	testb  $0x1,(%eax)
801066f3:	75 45                	jne    8010673a <mappages+0x7a>
      panic("remap");
    *pte = pa | perm | PTE_P;
801066f5:	0b 5d 0c             	or     0xc(%ebp),%ebx
801066f8:	83 cb 01             	or     $0x1,%ebx
801066fb:	89 18                	mov    %ebx,(%eax)
    if(a == last)
801066fd:	3b 75 e0             	cmp    -0x20(%ebp),%esi
80106700:	74 2e                	je     80106730 <mappages+0x70>
      break;
    a += PGSIZE;
80106702:	81 c6 00 10 00 00    	add    $0x1000,%esi
  for(;;){
80106708:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010670b:	b9 01 00 00 00       	mov    $0x1,%ecx
80106710:	89 f2                	mov    %esi,%edx
80106712:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80106715:	89 f8                	mov    %edi,%eax
80106717:	e8 24 ff ff ff       	call   80106640 <walkpgdir>
8010671c:	85 c0                	test   %eax,%eax
8010671e:	75 d0                	jne    801066f0 <mappages+0x30>
    pa += PGSIZE;
  }
  return 0;
}
80106720:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106723:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106728:	5b                   	pop    %ebx
80106729:	5e                   	pop    %esi
8010672a:	5f                   	pop    %edi
8010672b:	5d                   	pop    %ebp
8010672c:	c3                   	ret
8010672d:	8d 76 00             	lea    0x0(%esi),%esi
80106730:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106733:	31 c0                	xor    %eax,%eax
}
80106735:	5b                   	pop    %ebx
80106736:	5e                   	pop    %esi
80106737:	5f                   	pop    %edi
80106738:	5d                   	pop    %ebp
80106739:	c3                   	ret
      panic("remap");
8010673a:	83 ec 0c             	sub    $0xc,%esp
8010673d:	68 60 73 10 80       	push   $0x80107360
80106742:	e8 39 9c ff ff       	call   80100380 <panic>
80106747:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010674e:	00 
8010674f:	90                   	nop

80106750 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106750:	55                   	push   %ebp
80106751:	89 e5                	mov    %esp,%ebp
80106753:	57                   	push   %edi
80106754:	56                   	push   %esi
80106755:	89 c6                	mov    %eax,%esi
80106757:	53                   	push   %ebx
80106758:	89 d3                	mov    %edx,%ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
8010675a:	8d 91 ff 0f 00 00    	lea    0xfff(%ecx),%edx
80106760:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106766:	83 ec 1c             	sub    $0x1c,%esp
80106769:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010676c:	39 da                	cmp    %ebx,%edx
8010676e:	73 5b                	jae    801067cb <deallocuvm.part.0+0x7b>
80106770:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80106773:	89 d7                	mov    %edx,%edi
80106775:	eb 14                	jmp    8010678b <deallocuvm.part.0+0x3b>
80106777:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
8010677e:	00 
8010677f:	90                   	nop
80106780:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106786:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80106789:	76 40                	jbe    801067cb <deallocuvm.part.0+0x7b>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010678b:	31 c9                	xor    %ecx,%ecx
8010678d:	89 fa                	mov    %edi,%edx
8010678f:	89 f0                	mov    %esi,%eax
80106791:	e8 aa fe ff ff       	call   80106640 <walkpgdir>
80106796:	89 c3                	mov    %eax,%ebx
    if(!pte)
80106798:	85 c0                	test   %eax,%eax
8010679a:	74 44                	je     801067e0 <deallocuvm.part.0+0x90>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
8010679c:	8b 00                	mov    (%eax),%eax
8010679e:	a8 01                	test   $0x1,%al
801067a0:	74 de                	je     80106780 <deallocuvm.part.0+0x30>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
801067a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801067a7:	74 47                	je     801067f0 <deallocuvm.part.0+0xa0>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
801067a9:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
801067ac:	05 00 00 00 80       	add    $0x80000000,%eax
801067b1:	81 c7 00 10 00 00    	add    $0x1000,%edi
      kfree(v);
801067b7:	50                   	push   %eax
801067b8:	e8 e3 bc ff ff       	call   801024a0 <kfree>
      *pte = 0;
801067bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
801067c3:	83 c4 10             	add    $0x10,%esp
  for(; a  < oldsz; a += PGSIZE){
801067c6:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
801067c9:	77 c0                	ja     8010678b <deallocuvm.part.0+0x3b>
    }
  }
  return newsz;
}
801067cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801067ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
801067d1:	5b                   	pop    %ebx
801067d2:	5e                   	pop    %esi
801067d3:	5f                   	pop    %edi
801067d4:	5d                   	pop    %ebp
801067d5:	c3                   	ret
801067d6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801067dd:	00 
801067de:	66 90                	xchg   %ax,%ax
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801067e0:	89 fa                	mov    %edi,%edx
801067e2:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
801067e8:	8d ba 00 00 40 00    	lea    0x400000(%edx),%edi
801067ee:	eb 96                	jmp    80106786 <deallocuvm.part.0+0x36>
        panic("kfree");
801067f0:	83 ec 0c             	sub    $0xc,%esp
801067f3:	68 2c 71 10 80       	push   $0x8010712c
801067f8:	e8 83 9b ff ff       	call   80100380 <panic>
801067fd:	8d 76 00             	lea    0x0(%esi),%esi

80106800 <seginit>:
{
80106800:	55                   	push   %ebp
80106801:	89 e5                	mov    %esp,%ebp
80106803:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
80106806:	e8 f5 d0 ff ff       	call   80103900 <cpuid>
  pd[0] = size-1;
8010680b:	ba 2f 00 00 00       	mov    $0x2f,%edx
80106810:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106816:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010681a:	c7 80 d8 a8 15 88 ff 	movl   $0xffff,-0x77ea5728(%eax)
80106821:	ff 00 00 
80106824:	c7 80 dc a8 15 88 00 	movl   $0xcf9a00,-0x77ea5724(%eax)
8010682b:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
8010682e:	c7 80 e0 a8 15 88 ff 	movl   $0xffff,-0x77ea5720(%eax)
80106835:	ff 00 00 
80106838:	c7 80 e4 a8 15 88 00 	movl   $0xcf9200,-0x77ea571c(%eax)
8010683f:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80106842:	c7 80 e8 a8 15 88 ff 	movl   $0xffff,-0x77ea5718(%eax)
80106849:	ff 00 00 
8010684c:	c7 80 ec a8 15 88 00 	movl   $0xcffa00,-0x77ea5714(%eax)
80106853:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80106856:	c7 80 f0 a8 15 88 ff 	movl   $0xffff,-0x77ea5710(%eax)
8010685d:	ff 00 00 
80106860:	c7 80 f4 a8 15 88 00 	movl   $0xcff200,-0x77ea570c(%eax)
80106867:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
8010686a:	05 d0 a8 15 88       	add    $0x8815a8d0,%eax
  pd[1] = (uint)p;
8010686f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106873:	c1 e8 10             	shr    $0x10,%eax
80106876:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010687a:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010687d:	0f 01 10             	lgdtl  (%eax)
}
80106880:	c9                   	leave
80106881:	c3                   	ret
80106882:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106889:	00 
8010688a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106890 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106890:	a1 84 d5 15 88       	mov    0x8815d584,%eax
80106895:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010689a:	0f 22 d8             	mov    %eax,%cr3
}
8010689d:	c3                   	ret
8010689e:	66 90                	xchg   %ax,%ax

801068a0 <switchuvm>:
{
801068a0:	55                   	push   %ebp
801068a1:	89 e5                	mov    %esp,%ebp
801068a3:	57                   	push   %edi
801068a4:	56                   	push   %esi
801068a5:	53                   	push   %ebx
801068a6:	83 ec 1c             	sub    $0x1c,%esp
801068a9:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801068ac:	85 f6                	test   %esi,%esi
801068ae:	0f 84 cb 00 00 00    	je     8010697f <switchuvm+0xdf>
  if(p->kstack == 0)
801068b4:	8b 46 08             	mov    0x8(%esi),%eax
801068b7:	85 c0                	test   %eax,%eax
801068b9:	0f 84 da 00 00 00    	je     80106999 <switchuvm+0xf9>
  if(p->pgdir == 0)
801068bf:	8b 46 04             	mov    0x4(%esi),%eax
801068c2:	85 c0                	test   %eax,%eax
801068c4:	0f 84 c2 00 00 00    	je     8010698c <switchuvm+0xec>
  pushcli();
801068ca:	e8 e1 da ff ff       	call   801043b0 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801068cf:	e8 bc cf ff ff       	call   80103890 <mycpu>
801068d4:	89 c3                	mov    %eax,%ebx
801068d6:	e8 b5 cf ff ff       	call   80103890 <mycpu>
801068db:	89 c7                	mov    %eax,%edi
801068dd:	e8 ae cf ff ff       	call   80103890 <mycpu>
801068e2:	83 c7 08             	add    $0x8,%edi
801068e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801068e8:	e8 a3 cf ff ff       	call   80103890 <mycpu>
801068ed:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801068f0:	ba 67 00 00 00       	mov    $0x67,%edx
801068f5:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801068fc:	83 c0 08             	add    $0x8,%eax
801068ff:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106906:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010690b:	83 c1 08             	add    $0x8,%ecx
8010690e:	c1 e8 18             	shr    $0x18,%eax
80106911:	c1 e9 10             	shr    $0x10,%ecx
80106914:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
8010691a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106920:	b9 99 40 00 00       	mov    $0x4099,%ecx
80106925:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010692c:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80106931:	e8 5a cf ff ff       	call   80103890 <mycpu>
80106936:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010693d:	e8 4e cf ff ff       	call   80103890 <mycpu>
80106942:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106946:	8b 5e 08             	mov    0x8(%esi),%ebx
80106949:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010694f:	e8 3c cf ff ff       	call   80103890 <mycpu>
80106954:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106957:	e8 34 cf ff ff       	call   80103890 <mycpu>
8010695c:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106960:	b8 28 00 00 00       	mov    $0x28,%eax
80106965:	0f 00 d8             	ltr    %eax
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106968:	8b 46 04             	mov    0x4(%esi),%eax
8010696b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106970:	0f 22 d8             	mov    %eax,%cr3
}
80106973:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106976:	5b                   	pop    %ebx
80106977:	5e                   	pop    %esi
80106978:	5f                   	pop    %edi
80106979:	5d                   	pop    %ebp
  popcli();
8010697a:	e9 81 da ff ff       	jmp    80104400 <popcli>
    panic("switchuvm: no process");
8010697f:	83 ec 0c             	sub    $0xc,%esp
80106982:	68 66 73 10 80       	push   $0x80107366
80106987:	e8 f4 99 ff ff       	call   80100380 <panic>
    panic("switchuvm: no pgdir");
8010698c:	83 ec 0c             	sub    $0xc,%esp
8010698f:	68 91 73 10 80       	push   $0x80107391
80106994:	e8 e7 99 ff ff       	call   80100380 <panic>
    panic("switchuvm: no kstack");
80106999:	83 ec 0c             	sub    $0xc,%esp
8010699c:	68 7c 73 10 80       	push   $0x8010737c
801069a1:	e8 da 99 ff ff       	call   80100380 <panic>
801069a6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
801069ad:	00 
801069ae:	66 90                	xchg   %ax,%ax

801069b0 <inituvm>:
{
801069b0:	55                   	push   %ebp
801069b1:	89 e5                	mov    %esp,%ebp
801069b3:	57                   	push   %edi
801069b4:	56                   	push   %esi
801069b5:	53                   	push   %ebx
801069b6:	83 ec 1c             	sub    $0x1c,%esp
801069b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801069bc:	8b 75 10             	mov    0x10(%ebp),%esi
801069bf:	8b 7d 08             	mov    0x8(%ebp),%edi
801069c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
801069c5:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801069cb:	77 4b                	ja     80106a18 <inituvm+0x68>
  mem = kalloc();
801069cd:	e8 8e bc ff ff       	call   80102660 <kalloc>
  memset(mem, 0, PGSIZE);
801069d2:	83 ec 04             	sub    $0x4,%esp
801069d5:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
801069da:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801069dc:	6a 00                	push   $0x0
801069de:	50                   	push   %eax
801069df:	e8 cc db ff ff       	call   801045b0 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801069e4:	58                   	pop    %eax
801069e5:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801069eb:	5a                   	pop    %edx
801069ec:	6a 06                	push   $0x6
801069ee:	b9 00 10 00 00       	mov    $0x1000,%ecx
801069f3:	31 d2                	xor    %edx,%edx
801069f5:	50                   	push   %eax
801069f6:	89 f8                	mov    %edi,%eax
801069f8:	e8 c3 fc ff ff       	call   801066c0 <mappages>
  memmove(mem, init, sz);
801069fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a00:	89 75 10             	mov    %esi,0x10(%ebp)
80106a03:	83 c4 10             	add    $0x10,%esp
80106a06:	89 5d 08             	mov    %ebx,0x8(%ebp)
80106a09:	89 45 0c             	mov    %eax,0xc(%ebp)
}
80106a0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a0f:	5b                   	pop    %ebx
80106a10:	5e                   	pop    %esi
80106a11:	5f                   	pop    %edi
80106a12:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80106a13:	e9 38 dc ff ff       	jmp    80104650 <memmove>
    panic("inituvm: more than a page");
80106a18:	83 ec 0c             	sub    $0xc,%esp
80106a1b:	68 a5 73 10 80       	push   $0x801073a5
80106a20:	e8 5b 99 ff ff       	call   80100380 <panic>
80106a25:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106a2c:	00 
80106a2d:	8d 76 00             	lea    0x0(%esi),%esi

80106a30 <loaduvm>:
{
80106a30:	55                   	push   %ebp
80106a31:	89 e5                	mov    %esp,%ebp
80106a33:	57                   	push   %edi
80106a34:	56                   	push   %esi
80106a35:	53                   	push   %ebx
80106a36:	83 ec 1c             	sub    $0x1c,%esp
80106a39:	8b 45 0c             	mov    0xc(%ebp),%eax
80106a3c:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
80106a3f:	a9 ff 0f 00 00       	test   $0xfff,%eax
80106a44:	0f 85 8d 00 00 00    	jne    80106ad7 <loaduvm+0xa7>
  for(i = 0; i < sz; i += PGSIZE){
80106a4a:	01 f0                	add    %esi,%eax
80106a4c:	89 f3                	mov    %esi,%ebx
80106a4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106a51:	8b 45 14             	mov    0x14(%ebp),%eax
80106a54:	01 f0                	add    %esi,%eax
80106a56:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
80106a59:	85 f6                	test   %esi,%esi
80106a5b:	75 11                	jne    80106a6e <loaduvm+0x3e>
80106a5d:	eb 61                	jmp    80106ac0 <loaduvm+0x90>
80106a5f:	90                   	nop
80106a60:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
80106a66:	89 f0                	mov    %esi,%eax
80106a68:	29 d8                	sub    %ebx,%eax
80106a6a:	39 c6                	cmp    %eax,%esi
80106a6c:	76 52                	jbe    80106ac0 <loaduvm+0x90>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106a6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106a71:	8b 45 08             	mov    0x8(%ebp),%eax
80106a74:	31 c9                	xor    %ecx,%ecx
80106a76:	29 da                	sub    %ebx,%edx
80106a78:	e8 c3 fb ff ff       	call   80106640 <walkpgdir>
80106a7d:	85 c0                	test   %eax,%eax
80106a7f:	74 49                	je     80106aca <loaduvm+0x9a>
    pa = PTE_ADDR(*pte);
80106a81:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106a83:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
80106a86:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80106a8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106a90:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
80106a96:	0f 46 fb             	cmovbe %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106a99:	29 d9                	sub    %ebx,%ecx
80106a9b:	05 00 00 00 80       	add    $0x80000000,%eax
80106aa0:	57                   	push   %edi
80106aa1:	51                   	push   %ecx
80106aa2:	50                   	push   %eax
80106aa3:	ff 75 10             	push   0x10(%ebp)
80106aa6:	e8 05 b0 ff ff       	call   80101ab0 <readi>
80106aab:	83 c4 10             	add    $0x10,%esp
80106aae:	39 f8                	cmp    %edi,%eax
80106ab0:	74 ae                	je     80106a60 <loaduvm+0x30>
}
80106ab2:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106aba:	5b                   	pop    %ebx
80106abb:	5e                   	pop    %esi
80106abc:	5f                   	pop    %edi
80106abd:	5d                   	pop    %ebp
80106abe:	c3                   	ret
80106abf:	90                   	nop
80106ac0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106ac3:	31 c0                	xor    %eax,%eax
}
80106ac5:	5b                   	pop    %ebx
80106ac6:	5e                   	pop    %esi
80106ac7:	5f                   	pop    %edi
80106ac8:	5d                   	pop    %ebp
80106ac9:	c3                   	ret
      panic("loaduvm: address should exist");
80106aca:	83 ec 0c             	sub    $0xc,%esp
80106acd:	68 bf 73 10 80       	push   $0x801073bf
80106ad2:	e8 a9 98 ff ff       	call   80100380 <panic>
    panic("loaduvm: addr must be page aligned");
80106ad7:	83 ec 0c             	sub    $0xc,%esp
80106ada:	68 e0 75 10 80       	push   $0x801075e0
80106adf:	e8 9c 98 ff ff       	call   80100380 <panic>
80106ae4:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106aeb:	00 
80106aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106af0 <allocuvm>:
{
80106af0:	55                   	push   %ebp
80106af1:	89 e5                	mov    %esp,%ebp
80106af3:	57                   	push   %edi
80106af4:	56                   	push   %esi
80106af5:	53                   	push   %ebx
80106af6:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80106af9:	8b 45 10             	mov    0x10(%ebp),%eax
{
80106afc:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
80106aff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b02:	85 c0                	test   %eax,%eax
80106b04:	0f 88 b6 00 00 00    	js     80106bc0 <allocuvm+0xd0>
  if(newsz < oldsz)
80106b0a:	3b 45 0c             	cmp    0xc(%ebp),%eax
    return oldsz;
80106b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(newsz < oldsz)
80106b10:	0f 82 9a 00 00 00    	jb     80106bb0 <allocuvm+0xc0>
  a = PGROUNDUP(oldsz);
80106b16:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80106b1c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106b22:	39 75 10             	cmp    %esi,0x10(%ebp)
80106b25:	77 44                	ja     80106b6b <allocuvm+0x7b>
80106b27:	e9 87 00 00 00       	jmp    80106bb3 <allocuvm+0xc3>
80106b2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    memset(mem, 0, PGSIZE);
80106b30:	83 ec 04             	sub    $0x4,%esp
80106b33:	68 00 10 00 00       	push   $0x1000
80106b38:	6a 00                	push   $0x0
80106b3a:	50                   	push   %eax
80106b3b:	e8 70 da ff ff       	call   801045b0 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106b40:	58                   	pop    %eax
80106b41:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106b47:	5a                   	pop    %edx
80106b48:	6a 06                	push   $0x6
80106b4a:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106b4f:	89 f2                	mov    %esi,%edx
80106b51:	50                   	push   %eax
80106b52:	89 f8                	mov    %edi,%eax
80106b54:	e8 67 fb ff ff       	call   801066c0 <mappages>
80106b59:	83 c4 10             	add    $0x10,%esp
80106b5c:	85 c0                	test   %eax,%eax
80106b5e:	78 78                	js     80106bd8 <allocuvm+0xe8>
  for(; a < newsz; a += PGSIZE){
80106b60:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106b66:	39 75 10             	cmp    %esi,0x10(%ebp)
80106b69:	76 48                	jbe    80106bb3 <allocuvm+0xc3>
    mem = kalloc();
80106b6b:	e8 f0 ba ff ff       	call   80102660 <kalloc>
80106b70:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80106b72:	85 c0                	test   %eax,%eax
80106b74:	75 ba                	jne    80106b30 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80106b76:	83 ec 0c             	sub    $0xc,%esp
80106b79:	68 dd 73 10 80       	push   $0x801073dd
80106b7e:	e8 2d 9b ff ff       	call   801006b0 <cprintf>
  if(newsz >= oldsz)
80106b83:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b86:	83 c4 10             	add    $0x10,%esp
80106b89:	39 45 10             	cmp    %eax,0x10(%ebp)
80106b8c:	74 32                	je     80106bc0 <allocuvm+0xd0>
80106b8e:	8b 55 10             	mov    0x10(%ebp),%edx
80106b91:	89 c1                	mov    %eax,%ecx
80106b93:	89 f8                	mov    %edi,%eax
80106b95:	e8 b6 fb ff ff       	call   80106750 <deallocuvm.part.0>
      return 0;
80106b9a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106ba1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ba7:	5b                   	pop    %ebx
80106ba8:	5e                   	pop    %esi
80106ba9:	5f                   	pop    %edi
80106baa:	5d                   	pop    %ebp
80106bab:	c3                   	ret
80106bac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
80106bb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}
80106bb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106bb9:	5b                   	pop    %ebx
80106bba:	5e                   	pop    %esi
80106bbb:	5f                   	pop    %edi
80106bbc:	5d                   	pop    %ebp
80106bbd:	c3                   	ret
80106bbe:	66 90                	xchg   %ax,%ax
    return 0;
80106bc0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106bc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106bcd:	5b                   	pop    %ebx
80106bce:	5e                   	pop    %esi
80106bcf:	5f                   	pop    %edi
80106bd0:	5d                   	pop    %ebp
80106bd1:	c3                   	ret
80106bd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
80106bd8:	83 ec 0c             	sub    $0xc,%esp
80106bdb:	68 f5 73 10 80       	push   $0x801073f5
80106be0:	e8 cb 9a ff ff       	call   801006b0 <cprintf>
  if(newsz >= oldsz)
80106be5:	8b 45 0c             	mov    0xc(%ebp),%eax
80106be8:	83 c4 10             	add    $0x10,%esp
80106beb:	39 45 10             	cmp    %eax,0x10(%ebp)
80106bee:	74 0c                	je     80106bfc <allocuvm+0x10c>
80106bf0:	8b 55 10             	mov    0x10(%ebp),%edx
80106bf3:	89 c1                	mov    %eax,%ecx
80106bf5:	89 f8                	mov    %edi,%eax
80106bf7:	e8 54 fb ff ff       	call   80106750 <deallocuvm.part.0>
      kfree(mem);
80106bfc:	83 ec 0c             	sub    $0xc,%esp
80106bff:	53                   	push   %ebx
80106c00:	e8 9b b8 ff ff       	call   801024a0 <kfree>
      return 0;
80106c05:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106c0c:	83 c4 10             	add    $0x10,%esp
}
80106c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106c15:	5b                   	pop    %ebx
80106c16:	5e                   	pop    %esi
80106c17:	5f                   	pop    %edi
80106c18:	5d                   	pop    %ebp
80106c19:	c3                   	ret
80106c1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106c20 <deallocuvm>:
{
80106c20:	55                   	push   %ebp
80106c21:	89 e5                	mov    %esp,%ebp
80106c23:	8b 55 0c             	mov    0xc(%ebp),%edx
80106c26:	8b 4d 10             	mov    0x10(%ebp),%ecx
80106c29:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
80106c2c:	39 d1                	cmp    %edx,%ecx
80106c2e:	73 10                	jae    80106c40 <deallocuvm+0x20>
}
80106c30:	5d                   	pop    %ebp
80106c31:	e9 1a fb ff ff       	jmp    80106750 <deallocuvm.part.0>
80106c36:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106c3d:	00 
80106c3e:	66 90                	xchg   %ax,%ax
80106c40:	89 d0                	mov    %edx,%eax
80106c42:	5d                   	pop    %ebp
80106c43:	c3                   	ret
80106c44:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106c4b:	00 
80106c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80106c50 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106c50:	55                   	push   %ebp
80106c51:	89 e5                	mov    %esp,%ebp
80106c53:	57                   	push   %edi
80106c54:	56                   	push   %esi
80106c55:	53                   	push   %ebx
80106c56:	83 ec 0c             	sub    $0xc,%esp
80106c59:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106c5c:	85 f6                	test   %esi,%esi
80106c5e:	74 59                	je     80106cb9 <freevm+0x69>
  if(newsz >= oldsz)
80106c60:	31 c9                	xor    %ecx,%ecx
80106c62:	ba 00 00 00 80       	mov    $0x80000000,%edx
80106c67:	89 f0                	mov    %esi,%eax
80106c69:	89 f3                	mov    %esi,%ebx
80106c6b:	e8 e0 fa ff ff       	call   80106750 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80106c70:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80106c76:	eb 0f                	jmp    80106c87 <freevm+0x37>
80106c78:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106c7f:	00 
80106c80:	83 c3 04             	add    $0x4,%ebx
80106c83:	39 df                	cmp    %ebx,%edi
80106c85:	74 23                	je     80106caa <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80106c87:	8b 03                	mov    (%ebx),%eax
80106c89:	a8 01                	test   $0x1,%al
80106c8b:	74 f3                	je     80106c80 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106c8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80106c92:	83 ec 0c             	sub    $0xc,%esp
80106c95:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106c98:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106c9d:	50                   	push   %eax
80106c9e:	e8 fd b7 ff ff       	call   801024a0 <kfree>
80106ca3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80106ca6:	39 df                	cmp    %ebx,%edi
80106ca8:	75 dd                	jne    80106c87 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80106caa:	89 75 08             	mov    %esi,0x8(%ebp)
}
80106cad:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106cb0:	5b                   	pop    %ebx
80106cb1:	5e                   	pop    %esi
80106cb2:	5f                   	pop    %edi
80106cb3:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80106cb4:	e9 e7 b7 ff ff       	jmp    801024a0 <kfree>
    panic("freevm: no pgdir");
80106cb9:	83 ec 0c             	sub    $0xc,%esp
80106cbc:	68 11 74 10 80       	push   $0x80107411
80106cc1:	e8 ba 96 ff ff       	call   80100380 <panic>
80106cc6:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106ccd:	00 
80106cce:	66 90                	xchg   %ax,%ax

80106cd0 <setupkvm>:
{
80106cd0:	55                   	push   %ebp
80106cd1:	89 e5                	mov    %esp,%ebp
80106cd3:	56                   	push   %esi
80106cd4:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106cd5:	e8 86 b9 ff ff       	call   80102660 <kalloc>
80106cda:	89 c6                	mov    %eax,%esi
80106cdc:	85 c0                	test   %eax,%eax
80106cde:	74 42                	je     80106d22 <setupkvm+0x52>
  memset(pgdir, 0, PGSIZE);
80106ce0:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106ce3:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
  memset(pgdir, 0, PGSIZE);
80106ce8:	68 00 10 00 00       	push   $0x1000
80106ced:	6a 00                	push   $0x0
80106cef:	50                   	push   %eax
80106cf0:	e8 bb d8 ff ff       	call   801045b0 <memset>
80106cf5:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
80106cf8:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106cfb:	83 ec 08             	sub    $0x8,%esp
80106cfe:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106d01:	ff 73 0c             	push   0xc(%ebx)
80106d04:	8b 13                	mov    (%ebx),%edx
80106d06:	50                   	push   %eax
80106d07:	29 c1                	sub    %eax,%ecx
80106d09:	89 f0                	mov    %esi,%eax
80106d0b:	e8 b0 f9 ff ff       	call   801066c0 <mappages>
80106d10:	83 c4 10             	add    $0x10,%esp
80106d13:	85 c0                	test   %eax,%eax
80106d15:	78 19                	js     80106d30 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106d17:	83 c3 10             	add    $0x10,%ebx
80106d1a:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106d20:	75 d6                	jne    80106cf8 <setupkvm+0x28>
}
80106d22:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106d25:	89 f0                	mov    %esi,%eax
80106d27:	5b                   	pop    %ebx
80106d28:	5e                   	pop    %esi
80106d29:	5d                   	pop    %ebp
80106d2a:	c3                   	ret
80106d2b:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
      freevm(pgdir);
80106d30:	83 ec 0c             	sub    $0xc,%esp
80106d33:	56                   	push   %esi
      return 0;
80106d34:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
80106d36:	e8 15 ff ff ff       	call   80106c50 <freevm>
      return 0;
80106d3b:	83 c4 10             	add    $0x10,%esp
}
80106d3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106d41:	89 f0                	mov    %esi,%eax
80106d43:	5b                   	pop    %ebx
80106d44:	5e                   	pop    %esi
80106d45:	5d                   	pop    %ebp
80106d46:	c3                   	ret
80106d47:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106d4e:	00 
80106d4f:	90                   	nop

80106d50 <kvmalloc>:
{
80106d50:	55                   	push   %ebp
80106d51:	89 e5                	mov    %esp,%ebp
80106d53:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106d56:	e8 75 ff ff ff       	call   80106cd0 <setupkvm>
80106d5b:	a3 84 d5 15 88       	mov    %eax,0x8815d584
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106d60:	05 00 00 00 80       	add    $0x80000000,%eax
80106d65:	0f 22 d8             	mov    %eax,%cr3
}
80106d68:	c9                   	leave
80106d69:	c3                   	ret
80106d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106d70 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106d70:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106d71:	31 c9                	xor    %ecx,%ecx
{
80106d73:	89 e5                	mov    %esp,%ebp
80106d75:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80106d78:	8b 55 0c             	mov    0xc(%ebp),%edx
80106d7b:	8b 45 08             	mov    0x8(%ebp),%eax
80106d7e:	e8 bd f8 ff ff       	call   80106640 <walkpgdir>
  if(pte == 0)
80106d83:	85 c0                	test   %eax,%eax
80106d85:	74 05                	je     80106d8c <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106d87:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106d8a:	c9                   	leave
80106d8b:	c3                   	ret
    panic("clearpteu");
80106d8c:	83 ec 0c             	sub    $0xc,%esp
80106d8f:	68 22 74 10 80       	push   $0x80107422
80106d94:	e8 e7 95 ff ff       	call   80100380 <panic>
80106d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106da0 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106da0:	55                   	push   %ebp
80106da1:	89 e5                	mov    %esp,%ebp
80106da3:	57                   	push   %edi
80106da4:	56                   	push   %esi
80106da5:	53                   	push   %ebx
80106da6:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106da9:	e8 22 ff ff ff       	call   80106cd0 <setupkvm>
80106dae:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106db1:	85 c0                	test   %eax,%eax
80106db3:	0f 84 9f 00 00 00    	je     80106e58 <copyuvm+0xb8>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106db9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106dbc:	85 c9                	test   %ecx,%ecx
80106dbe:	0f 84 94 00 00 00    	je     80106e58 <copyuvm+0xb8>
80106dc4:	31 f6                	xor    %esi,%esi
80106dc6:	eb 4a                	jmp    80106e12 <copyuvm+0x72>
80106dc8:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106dcf:	00 
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106dd0:	83 ec 04             	sub    $0x4,%esp
80106dd3:	81 c7 00 00 00 80    	add    $0x80000000,%edi
80106dd9:	68 00 10 00 00       	push   $0x1000
80106dde:	57                   	push   %edi
80106ddf:	50                   	push   %eax
80106de0:	e8 6b d8 ff ff       	call   80104650 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106de5:	58                   	pop    %eax
80106de6:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106dec:	5a                   	pop    %edx
80106ded:	ff 75 e4             	push   -0x1c(%ebp)
80106df0:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106df5:	89 f2                	mov    %esi,%edx
80106df7:	50                   	push   %eax
80106df8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106dfb:	e8 c0 f8 ff ff       	call   801066c0 <mappages>
80106e00:	83 c4 10             	add    $0x10,%esp
80106e03:	85 c0                	test   %eax,%eax
80106e05:	78 61                	js     80106e68 <copyuvm+0xc8>
  for(i = 0; i < sz; i += PGSIZE){
80106e07:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106e0d:	39 75 0c             	cmp    %esi,0xc(%ebp)
80106e10:	76 46                	jbe    80106e58 <copyuvm+0xb8>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106e12:	8b 45 08             	mov    0x8(%ebp),%eax
80106e15:	31 c9                	xor    %ecx,%ecx
80106e17:	89 f2                	mov    %esi,%edx
80106e19:	e8 22 f8 ff ff       	call   80106640 <walkpgdir>
80106e1e:	85 c0                	test   %eax,%eax
80106e20:	74 61                	je     80106e83 <copyuvm+0xe3>
    if(!(*pte & PTE_P))
80106e22:	8b 00                	mov    (%eax),%eax
80106e24:	a8 01                	test   $0x1,%al
80106e26:	74 4e                	je     80106e76 <copyuvm+0xd6>
    pa = PTE_ADDR(*pte);
80106e28:	89 c7                	mov    %eax,%edi
    flags = PTE_FLAGS(*pte);
80106e2a:	25 ff 0f 00 00       	and    $0xfff,%eax
80106e2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
80106e32:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
80106e38:	e8 23 b8 ff ff       	call   80102660 <kalloc>
80106e3d:	89 c3                	mov    %eax,%ebx
80106e3f:	85 c0                	test   %eax,%eax
80106e41:	75 8d                	jne    80106dd0 <copyuvm+0x30>
    }
  }
  return d;

bad:
  freevm(d);
80106e43:	83 ec 0c             	sub    $0xc,%esp
80106e46:	ff 75 e0             	push   -0x20(%ebp)
80106e49:	e8 02 fe ff ff       	call   80106c50 <freevm>
  return 0;
80106e4e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80106e55:	83 c4 10             	add    $0x10,%esp
}
80106e58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106e5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e5e:	5b                   	pop    %ebx
80106e5f:	5e                   	pop    %esi
80106e60:	5f                   	pop    %edi
80106e61:	5d                   	pop    %ebp
80106e62:	c3                   	ret
80106e63:	2e 8d 74 26 00       	lea    %cs:0x0(%esi,%eiz,1),%esi
      kfree(mem);
80106e68:	83 ec 0c             	sub    $0xc,%esp
80106e6b:	53                   	push   %ebx
80106e6c:	e8 2f b6 ff ff       	call   801024a0 <kfree>
      goto bad;
80106e71:	83 c4 10             	add    $0x10,%esp
80106e74:	eb cd                	jmp    80106e43 <copyuvm+0xa3>
      panic("copyuvm: page not present");
80106e76:	83 ec 0c             	sub    $0xc,%esp
80106e79:	68 46 74 10 80       	push   $0x80107446
80106e7e:	e8 fd 94 ff ff       	call   80100380 <panic>
      panic("copyuvm: pte should exist");
80106e83:	83 ec 0c             	sub    $0xc,%esp
80106e86:	68 2c 74 10 80       	push   $0x8010742c
80106e8b:	e8 f0 94 ff ff       	call   80100380 <panic>

80106e90 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106e90:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106e91:	31 c9                	xor    %ecx,%ecx
{
80106e93:	89 e5                	mov    %esp,%ebp
80106e95:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
80106e98:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e9e:	e8 9d f7 ff ff       	call   80106640 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106ea3:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80106ea5:	c9                   	leave
  if((*pte & PTE_U) == 0)
80106ea6:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80106ea8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80106ead:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80106eb0:	05 00 00 00 80       	add    $0x80000000,%eax
80106eb5:	83 fa 05             	cmp    $0x5,%edx
80106eb8:	ba 00 00 00 00       	mov    $0x0,%edx
80106ebd:	0f 45 c2             	cmovne %edx,%eax
}
80106ec0:	c3                   	ret
80106ec1:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106ec8:	00 
80106ec9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106ed0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106ed0:	55                   	push   %ebp
80106ed1:	89 e5                	mov    %esp,%ebp
80106ed3:	57                   	push   %edi
80106ed4:	56                   	push   %esi
80106ed5:	53                   	push   %ebx
80106ed6:	83 ec 0c             	sub    $0xc,%esp
80106ed9:	8b 75 14             	mov    0x14(%ebp),%esi
80106edc:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106edf:	85 f6                	test   %esi,%esi
80106ee1:	75 38                	jne    80106f1b <copyout+0x4b>
80106ee3:	eb 6b                	jmp    80106f50 <copyout+0x80>
80106ee5:	8d 76 00             	lea    0x0(%esi),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80106ee8:	8b 55 0c             	mov    0xc(%ebp),%edx
80106eeb:	89 fb                	mov    %edi,%ebx
80106eed:	29 d3                	sub    %edx,%ebx
80106eef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106ef5:	39 f3                	cmp    %esi,%ebx
80106ef7:	0f 47 de             	cmova  %esi,%ebx
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106efa:	29 fa                	sub    %edi,%edx
80106efc:	83 ec 04             	sub    $0x4,%esp
80106eff:	01 c2                	add    %eax,%edx
80106f01:	53                   	push   %ebx
80106f02:	ff 75 10             	push   0x10(%ebp)
80106f05:	52                   	push   %edx
80106f06:	e8 45 d7 ff ff       	call   80104650 <memmove>
    len -= n;
    buf += n;
80106f0b:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106f0e:	8d 97 00 10 00 00    	lea    0x1000(%edi),%edx
  while(len > 0){
80106f14:	83 c4 10             	add    $0x10,%esp
80106f17:	29 de                	sub    %ebx,%esi
80106f19:	74 35                	je     80106f50 <copyout+0x80>
    va0 = (uint)PGROUNDDOWN(va);
80106f1b:	89 d7                	mov    %edx,%edi
    pa0 = uva2ka(pgdir, (char*)va0);
80106f1d:	83 ec 08             	sub    $0x8,%esp
    va0 = (uint)PGROUNDDOWN(va);
80106f20:	89 55 0c             	mov    %edx,0xc(%ebp)
80106f23:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    pa0 = uva2ka(pgdir, (char*)va0);
80106f29:	57                   	push   %edi
80106f2a:	ff 75 08             	push   0x8(%ebp)
80106f2d:	e8 5e ff ff ff       	call   80106e90 <uva2ka>
    if(pa0 == 0)
80106f32:	83 c4 10             	add    $0x10,%esp
80106f35:	85 c0                	test   %eax,%eax
80106f37:	75 af                	jne    80106ee8 <copyout+0x18>
  }
  return 0;
}
80106f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106f3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106f41:	5b                   	pop    %ebx
80106f42:	5e                   	pop    %esi
80106f43:	5f                   	pop    %edi
80106f44:	5d                   	pop    %ebp
80106f45:	c3                   	ret
80106f46:	2e 8d b4 26 00 00 00 	lea    %cs:0x0(%esi,%eiz,1),%esi
80106f4d:	00 
80106f4e:	66 90                	xchg   %ax,%ax
80106f50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106f53:	31 c0                	xor    %eax,%eax
}
80106f55:	5b                   	pop    %ebx
80106f56:	5e                   	pop    %esi
80106f57:	5f                   	pop    %edi
80106f58:	5d                   	pop    %ebp
80106f59:	c3                   	ret
