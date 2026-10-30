# Tang Nano 9K Vending Machine

Tang Nano 9K (`GW1NR-LV9QN88PC6/I5`) için Gowin EDA projesi. Verilog sürümünü `vending_machine.gprj`, VHDL sürümünü `vending_machine_vhdl.gprj` ile açın. İki proje de aynı `.cst` pin eşlemesini kullanır.

## Butonlar

- S1 / pin 3: Bakiye 50'nin altındayken her basışta 10 birim ekler. Bakiye 50 iken tekrar basıldığında 30 birimlik ürünü alır ve bakiyeden 30 düşer.
- S2 / pin 4: Bakiye en az 50 ise 50 birimlik ürünü alır; değilse yetersiz bakiye göstergesi yanar.

## LED'ler

- Pin 10: 30 birimlik ürün alındı.
- Pin 11: 50 birimlik ürün alındı.
- Pin 13: yetersiz bakiye.
- Pin 14: bakiye en az 50.

Saat pin 52'deki 27 MHz osilatördür. Butonlar ve LED'ler aktif düşük çalışır. Butonlar senkronize edilip 10 ms debounce edilir. Durum LED'leri yeni bir başarılı alışverişe kadar yanık kalır; 50 birim eşiği LED'i bakiyeyi takip eder.
