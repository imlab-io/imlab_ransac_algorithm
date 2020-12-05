---
layout: post
title: RANSAC Algoritması ile Doğru Uyumlama
slug: ransac-algorithm
author: Bahri ABACI
categories:
- Makine Öğrenmesi
- Nümerik Yöntemler
- Veri Analizi
references: "Random sample consensus: a paradigm for model fitting with applications to image analysis and automated cartography"
thumbnail: /assets/post_resources/ransac_algorithm/thumbnail.svg
---
RANSAC (Random Sample and Consensus); gürültülü veriler üzerinde makine öğrenmesi ve veri analizi algoritmalarının gürbüz şekilde çalışabilmesi için kullanılan bir yöntemdir. Yöntem ilk olarak 1981 yılında Fischler ve Bolles tarafından konum belirleme problemlerinde karşılaşılan gürültülü (noisy) ve aykırı (outlier) veri sorununu ortadan kaldırmak için önerilmiştir. Bugüne kadar 24 binin üzerinde atıf alan yöntem, aykırı veri tespiti veya gürültüden bağımsız model uyumlama problemlerinde akla gelen ilk yöntemdir. Bu yazımızda RANSAC algoritmasının çalışma mantığından bahsettikten sonra, basit bir doğru uyumlama probleminde ne şekilde bir katkı sağladığı incelenecektir.

<!--more-->

Önceki yazılarımızda incelediğimiz makine öğrenmesi ve veri analizi yöntemlerinde veri üzerinden nümerik yöntemler ile sonuca ulaşmaya çalışmıştık. Bu yöntemlerde, verinin gürültülü olması durumu da göz önünde bulundurarak, tanımlanan hata fonksiyonlarını sıfıra eşitlemeye değil ortalama karesel hata ölçütünde en küçüklemeye çalışmıştık. Elde ettiğimiz yöntemler gerçek hayatta karşılaştığımız pek çok gürültü tipi için (normal, düzgün dağılımlı gürültü) istenilen sonuçları üretse de mühendislik problemlerinde karşılaşılan aykırı (outlier) tipte gürültüler için yeterli gürbüzlüğü sağlayamamaktadır. Bu yazımızın konusu olan RANSAC yöntemi aykırı tipte gürültülü veri içeren bir veri setinde önceki yazılarımızda incelediğimiz makine öğrenmesi ve veri analizi yöntemlerinin karalılığını artıran bir yöntemdir.

Yöntemin detaylarına geçmeden önce basit bir doğru uyumlama problemini daha önceki yazılarda yaptığımız şekilde çözmeye çalışalım.

Elimizde <img src="assets/post_resources/math//45f2dbf90251d9796e488d974777c8c8.svg?invert_in_darkmode" align=middle width=48.491328599999996pt height=24.65753399999998pt/> şeklinde verilen <img src="assets/post_resources/math//f9c4988898e7f532b9f826a75014ed3c.svg?invert_in_darkmode" align=middle width=14.99998994999999pt height=22.465723500000017pt/> tane nokta olduğunu varsayalım. Doğru uyumlamada amaç, bu nokta çiftlerine <img src="assets/post_resources/math//1b0e189790b3874e11d0e0ce01a31e57.svg?invert_in_darkmode" align=middle width=91.89673184999998pt height=22.831056599999986pt/> şeklinde bir doğru ile en küçük hata ile uyum sağlayan <img src="assets/post_resources/math//d2f5922136085b5aa96baa7d38c2aebb.svg?invert_in_darkmode" align=middle width=41.57921294999999pt height=24.65753399999998pt/> parametreleri ile ifade edilen doğruyu bulmaktır. Problem, karesel hata fonksiyonunun en küçüklemesi şeklinde düşünülürse aşağıdaki hata denklemi yazılabilir.

<p align="center"><img src="assets/post_resources/math//a2f5dc2e5d645d1f4362f36ac60c7ba1.svg?invert_in_darkmode" align=middle width=227.37528329999998pt height=47.806078649999996pt/></p>

[Gradyan İniş Yöntemleri]({% post_url 2020-04-08-gradyan-yontemleri-ile-optimizasyon %}) yazımızda bahsettiğimiz şekilde, bu hata fonksiyonun en küçük noktası, <img src="assets/post_resources/math//0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode" align=middle width=14.433101099999991pt height=14.15524440000002pt/> ve <img src="assets/post_resources/math//4bdc8d9bcfb35e1c9bfb51fc69687dfc.svg?invert_in_darkmode" align=middle width=7.054796099999991pt height=22.831056599999986pt/> değerlerine göre türevler alınıp sıfıra eşitlenerek bulunabilir.

<p align="center"><img src="assets/post_resources/math//796723097dab6accd91200cbb93a825c.svg?invert_in_darkmode" align=middle width=480.44727555pt height=94.35183944999999pt/></p>

Denklem \ref{gradient} de görüldüğü üzere, <img src="assets/post_resources/math//0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode" align=middle width=14.433101099999991pt height=14.15524440000002pt/> ve <img src="assets/post_resources/math//4bdc8d9bcfb35e1c9bfb51fc69687dfc.svg?invert_in_darkmode" align=middle width=7.054796099999991pt height=22.831056599999986pt/> değişkenlerine en küçükleyen noktalar birbirine bağımlı olarak elde edilmektedir. Bu bağıntıdan kurtulmak için <img src="assets/post_resources/math//4bdc8d9bcfb35e1c9bfb51fc69687dfc.svg?invert_in_darkmode" align=middle width=7.054796099999991pt height=22.831056599999986pt/> için bulunan en iyi değer <img src="assets/post_resources/math//0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode" align=middle width=14.433101099999991pt height=14.15524440000002pt/> için elde edilen denklemde yerine yazılırsa;

<p align="center"><img src="assets/post_resources/math//2c486f88936ebbd6da86727789e5cd65.svg?invert_in_darkmode" align=middle width=346.63033844999995pt height=183.8331495pt/></p>

elde edilir. <img src="assets/post_resources/math//0e51a2dede42189d77627c4d742822c3.svg?invert_in_darkmode" align=middle width=14.433101099999991pt height=14.15524440000002pt/> değeri çözüldükten sonra <img src="assets/post_resources/math//4bdc8d9bcfb35e1c9bfb51fc69687dfc.svg?invert_in_darkmode" align=middle width=7.054796099999991pt height=22.831056599999986pt/> için elde edilen denklemde yerine yazılarak <img src="assets/post_resources/math//4bdc8d9bcfb35e1c9bfb51fc69687dfc.svg?invert_in_darkmode" align=middle width=7.054796099999991pt height=22.831056599999986pt/> noktasını en iyileyen çözüm de bulunabilir. Yukarıda matematiksel ifadesi verilen uyumlama işlemi C dilinde ```void fit(matrix_t *sdata, void *model)``` fonksiyonu ile gerçeklenmiştir. Fonksiyon <img src="assets/post_resources/math//29d4fbc40637a1ca9087e1f3351a25f1.svg?invert_in_darkmode" align=middle width=43.31036984999999pt height=22.465723500000017pt/> boyutunda verilen <img src="assets/post_resources/math//f9c4988898e7f532b9f826a75014ed3c.svg?invert_in_darkmode" align=middle width=14.99998994999999pt height=22.465723500000017pt/> tane <img src="assets/post_resources/math//45f2dbf90251d9796e488d974777c8c8.svg?invert_in_darkmode" align=middle width=48.491328599999996pt height=24.65753399999998pt/> veri çiftini girdi olarak almakta ve sonuçları ```model ``` ile verilen bellek alanına yazmaktadır.

Yazılan fonksiyonun farklı veri setleri üzerinde çalıştırılması sonucunda aşağıda verilen sonuçlar elde edilmiştir. Verilen grafikte koyu yeşil noktalar <img src="assets/post_resources/math//45f2dbf90251d9796e488d974777c8c8.svg?invert_in_darkmode" align=middle width=48.491328599999996pt height=24.65753399999998pt/> veri çiftlerini, siyah doğru <img src="assets/post_resources/math//700ba155db8b7deb4b6d0ce556bf36e5.svg?invert_in_darkmode" align=middle width=114.63832709999998pt height=24.65753399999998pt/> bu verilerin üretildiği referans doğruyu ve kırmızı doğru ise yazılan fonksiyonun çıktısını göstermektedir.

| Gürültüsüz Veri |  Az Gürültülü Veri | Orta Gürültülü Veri | Çok Gürültülü Veri |
:-------:|:----:|:----:|:---:|
![Doğru Uyumlama][linefit_example_n0] | ![Doğru Uyumlama][linefit_example_n1] | ![Doğru Uyumlama][linefit_example_n2] | ![Doğru Uyumlama][linefit_example_n3] |

Doğru uyumlaması testinde yöntemin gürbüzlüğünü analiz edebilmek için artan gürültü seviyelerinde 4 farklı veri kullanılmıştır. Şekilden de görüldüğü üzere yöntem düşük gürültülü veri setleri için gerçek doğruya oldukça yakın sonuçlar elde ederken artan gürültü seviyelerinde gürültülü veya aykırı verilerden oldukça etkilenerek hatalı sonuçlar üretmektedir.

### RANSAC Yöntemi

RANSAC yönteminin temel fikri; makine öğrenmesi aşamasında veri setinde bulunan örneklerin tamamının değil, rastgele seçilen alt kümelerinin (random sampling) kullanılmasına dayanmaktadır. Veri içerisinde aykırı ve gürültülü veriler gürültüsüz verilere kıyasla daha az olacağından, yeteri sayıda rastgele seçilen alt kümeler içerisinde gürültülü veya aykırı veri içermeyen bir alt küme elde edilecektir. Bu alt küme üzerinde eğitilen modelin veri setinde yer alan diğer verilerle de yüksek uyum (consensus) göstermesi beklenmektedir.

RANSAC yönteminde uyum ölçütü olarak, veri setinde yer alan tüm noktaların uyumlanan modele olan uzaklıkları ölçülmekte ve uzaklıkları <img src="assets/post_resources/math//0fe1677705e987cac4f589ed600aa6b3.svg?invert_in_darkmode" align=middle width=9.046852649999991pt height=14.15524440000002pt/> eşik değerinden küçük olan noktaların sayısı uyum büyüklüğünü göstermektedir. Bu sayede, alt kümeler üzerinden eğitilen modellerden veriye en yüksek uyum sağlayan modelin seçilmesi ile gürültü ve aykırı veriden etkilenmeyen bir model bulunabilecektir.

Aşağıda çok gürültülü veri için rastgele seçilen 4 farklı alt küme için doğru uyumlama sonuçları gösterilmiştir. Verilen grafiklerde koyu yeşil noktalar veri çiftlerini, açık yeşil noktalar rastgele örneklenen ve model uyumlamasında kullanılan veri çiftlerini göstermektedir. Siyah doğru <img src="assets/post_resources/math//700ba155db8b7deb4b6d0ce556bf36e5.svg?invert_in_darkmode" align=middle width=114.63832709999998pt height=24.65753399999998pt/> verilerin üretildiği referans doğruyu, kırmızı doğru yazılan fonksiyonun çıktısını ve kırmızı ile taralı alan ise uyumlanan modele uzaklığı <img src="assets/post_resources/math//981394445f981f48cd900c5a14028e2b.svg?invert_in_darkmode" align=middle width=51.969107849999986pt height=21.18721440000001pt/> den küçük olan noktalar kümesini göstermektedir.

| Rastgele Alt Küme 1 |  Rastgele Alt Küme 2 | Rastgele Alt Küme 3 | Rastgele Alt Küme 4 |
:-------:|:----:|:----:|:---:|
![Doğru Uyumlama][ransac_example_41] | ![Doğru Uyumlama][ransac_example_42] | ![Doğru Uyumlama][ransac_example_43] | ![Doğru Uyumlama][ransac_example_44] |

Şekilden de görüldüğü üzere 1,2 ve 3 numaralı alt kümeler üzerinden elde edilen model istediğimiz sonuçtan oldukça uzakken, 4 numaralı alt küme üzerinden uyumlanan model istediğimiz doğruya oldukça yakın bir sonuç üretmektedir. Burada uyumluluk ölçütü olarak kullanılan <img src="assets/post_resources/math//9ac49cb370a5b09fca29068ea18eab63.svg?invert_in_darkmode" align=middle width=51.969107849999986pt height=21.18721440000001pt/> eşik değerine göre birinci, ikinci ve üçüncü alt kümelerden elde edile modele göre 4 nokta, dördüncü alt kümeden elde edile modele göre ise 7 nokta uyum sağlamaktadır. Buradan da matematiksel olarak da 4 numaralı alt kümeden uyumlanan modelin en iyi model olduğu sonucuna ulaşılır.

Genel amaçlı bir makine öğrenmesi problemi için RANSAC yöntemi aşağıdaki algoritma adımları ile özetlenebilir.

> - **GİRDİLER**
>   - <img src="assets/post_resources/math//f156ed4a1ddd2045658314ad1205cd65.svg?invert_in_darkmode" align=middle width=136.73378895pt height=45.84475499999998pt/>: veri kümesi
>   - <img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/>: Rastgele seçilecek örnek sayısı
>   - <img src="assets/post_resources/math//0fe1677705e987cac4f589ed600aa6b3.svg?invert_in_darkmode" align=middle width=9.046852649999991pt height=14.15524440000002pt/>: Model ile veri arasındaki en büyük uzaklık
>   - <img src="assets/post_resources/math//2f118ee06d05f3c2d98361d9c30e38ce.svg?invert_in_darkmode" align=middle width=11.889314249999991pt height=22.465723500000017pt/>: İterasyon sayısı
> - **ÇIKTILAR**
>   - <img src="assets/post_resources/math//fb97d38bcc19230b0acd442e17db879c.svg?invert_in_darkmode" align=middle width=17.73973739999999pt height=22.465723500000017pt/>: Uyumlanan model
>
> *****************************
>
> - EnYuksekUyum = 0
> - t = 0
> - **while** t++ < <img src="assets/post_resources/math//2f118ee06d05f3c2d98361d9c30e38ce.svg?invert_in_darkmode" align=middle width=11.889314249999991pt height=22.465723500000017pt/>
>   - <img src="assets/post_resources/math//f9c4988898e7f532b9f826a75014ed3c.svg?invert_in_darkmode" align=middle width=14.99998994999999pt height=22.465723500000017pt/> veri-etiket çiftinden <img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/> tanesini rastgele örnekle, <img src="assets/post_resources/math//5be0ad25298e7f68beced752c79c53f6.svg?invert_in_darkmode" align=middle width=180.43084619999996pt height=22.831056599999986pt/>
>   - <img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/> tane veri üzerinden model uyumlama gerçekleştir, `fit(S, Model)`
>   - <img src="assets/post_resources/math//78ec2b7008296ce0561cf83393cb746d.svg?invert_in_darkmode" align=middle width=14.06623184999999pt height=22.465723500000017pt/> kümesi ile model uyumunu hesapla, <img src="assets/post_resources/math//d50aef36790c048b517db5bf747857d7.svg?invert_in_darkmode" align=middle width=291.98881965pt height=47.67123239999998pt/>
>   - **if** <img src="assets/post_resources/math//6dbb78540bd76da3f1625782d42d6d16.svg?invert_in_darkmode" align=middle width=9.41027339999999pt height=14.15524440000002pt/> > EnYuksekUyum
>     - <img src="assets/post_resources/math//fb97d38bcc19230b0acd442e17db879c.svg?invert_in_darkmode" align=middle width=17.73973739999999pt height=22.465723500000017pt/> = Model
>     - EnYuksekUyum = <img src="assets/post_resources/math//6dbb78540bd76da3f1625782d42d6d16.svg?invert_in_darkmode" align=middle width=9.41027339999999pt height=14.15524440000002pt/>
> - **return** <img src="assets/post_resources/math//fb97d38bcc19230b0acd442e17db879c.svg?invert_in_darkmode" align=middle width=17.73973739999999pt height=22.465723500000017pt/>

Yukarıda verilen sözde kodda da görüleceği üzere, RANSAC yönteminin üç önemli parametresi bulunmaktadır. Bu parametreler <img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/> her iterasyonda seçilecek örnek sayısı, <img src="assets/post_resources/math//0fe1677705e987cac4f589ed600aa6b3.svg?invert_in_darkmode" align=middle width=9.046852649999991pt height=14.15524440000002pt/> uyumlanan model ile veriler arasındaki kabul edilebilir en büyük uzaklık ve <img src="assets/post_resources/math//2f118ee06d05f3c2d98361d9c30e38ce.svg?invert_in_darkmode" align=middle width=11.889314249999991pt height=22.465723500000017pt/> iterasyon sayısıdır.

Her iterasyonda seçilecek örnek sayısının (<img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/>) alt sınırı verilen problemin analitik çözümü için gerekli en küçük veri sayısı olarak belirlenir. Örnek olarak doğru uyumlama için en az iki nokta gerektiğinden <img src="assets/post_resources/math//60fb0352eb5c4de0c09ed8259fb54053.svg?invert_in_darkmode" align=middle width=45.273840149999984pt height=22.465723500000017pt/>, perspektif dönüşümü için en az üç nokta gerektiğinden <img src="assets/post_resources/math//4b9326674e506f999a1430bd395b24c9.svg?invert_in_darkmode" align=middle width=45.273840149999984pt height=22.465723500000017pt/> olarak seçilmelidir. <img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/> sayısının büyük seçilmesi <img src="assets/post_resources/math//2f118ee06d05f3c2d98361d9c30e38ce.svg?invert_in_darkmode" align=middle width=11.889314249999991pt height=22.465723500000017pt/> iterasyon sayısını da artırdığında (açıklama aşağıda yapılmaktadır) genellikle seçimler alt sınıra eşit olacak şekilde yapılmaktadır.

<img src="assets/post_resources/math//0fe1677705e987cac4f589ed600aa6b3.svg?invert_in_darkmode" align=middle width=9.046852649999991pt height=14.15524440000002pt/>; uyumlanan model ile veriler arasındaki kabul edilebilir en büyük uzaklık, RANSAC yönteminde belirlemesi en zor parametrelerden biridir. Doğru uyumlama gibi basit bir problemde dahi eşik değeri veri görselleştirilmeden veya verideki gürültü oranı kestirilmeden bulunamamaktadır. Bu parametrenin seçimi için veri ön incelemeden geçirilmeli ve verinin birimine göre kabul edilebilir bir hata toleransı belirlenmelidir.

RANSAC yönteminin önemli bir diğer parametresi de <img src="assets/post_resources/math//2f118ee06d05f3c2d98361d9c30e38ce.svg?invert_in_darkmode" align=middle width=11.889314249999991pt height=22.465723500000017pt/> iterasyon/rastgele örnekleme sayısıdır. Seçilmesi gereken iterasyon sayısı kullanılan verideki aykırı veri oranına ve istenilen başarı olasılığına bağlı olarak değişmektedir. Veride yer alan aykırı veri oranı <img src="assets/post_resources/math//d5c18a8ca1894fd3a7d25f242cbe8890.svg?invert_in_darkmode" align=middle width=7.928106449999989pt height=14.15524440000002pt/>, model uyumlamada kullanılacak veri sayısı <img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/> ve istenilen başarı oranı <img src="assets/post_resources/math//2ec6e630f199f589a2402fdf3e0289d5.svg?invert_in_darkmode" align=middle width=8.270567249999992pt height=14.15524440000002pt/> ile ifade edilmesi durumunda gerekli <img src="assets/post_resources/math//2f118ee06d05f3c2d98361d9c30e38ce.svg?invert_in_darkmode" align=middle width=11.889314249999991pt height=22.465723500000017pt/> iterasyon sayısı aşağıdaki şekilde hesaplanır.

Örnekleme seçimleri birbirinden bağımsız varsayılırsa, <img src="assets/post_resources/math//f9c4988898e7f532b9f826a75014ed3c.svg?invert_in_darkmode" align=middle width=14.99998994999999pt height=22.465723500000017pt/> veriden <img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/> tane gürültüsüz veri seçme olasılığı = <img src="assets/post_resources/math//34d77240f3b06d800e1ba4b89ecc29ff.svg?invert_in_darkmode" align=middle width=60.87558839999999pt height=27.6567522pt/> dir. Buradan, seçilen <img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/> örnekte en az bir tane gürültülü veri olma olasılığı = <img src="assets/post_resources/math//871d6d900621c166c3c09b2c7c8cbcd9.svg?invert_in_darkmode" align=middle width=89.18598974999999pt height=27.6567522pt/> bulunur. Seçimin <img src="assets/post_resources/math//2f118ee06d05f3c2d98361d9c30e38ce.svg?invert_in_darkmode" align=middle width=11.889314249999991pt height=22.465723500000017pt/> kez tekrarlanması durumunda, her seçimde en az bir gürültülü örnek bulunması olasılığı = <img src="assets/post_resources/math//44f4a658a40f44bbcd3e3072eff8640f.svg?invert_in_darkmode" align=middle width=112.32705659999998pt height=27.6567522pt/> olarak hesaplanır. Bu olasılık aynı zamanda başarısızlık olasılığına da eşit olduğundan, <img src="assets/post_resources/math//4caa374ea7be3acf6e8cec8848601f2e.svg?invert_in_darkmode" align=middle width=170.82565499999998pt height=27.6567522pt/> yazılabilir. Buradan da;

<p align="center"><img src="assets/post_resources/math//5279af154dfe5f4cf2b454c26ac8d7ce.svg?invert_in_darkmode" align=middle width=159.8057868pt height=38.83491479999999pt/></p>

olarak hesaplanır. Aşağıda bazı örnek durumlar için gerekli iterasyon sayıları hesaplanmıştır.

| <img src="assets/post_resources/math//d5c18a8ca1894fd3a7d25f242cbe8890.svg?invert_in_darkmode" align=middle width=7.928106449999989pt height=14.15524440000002pt/> / <img src="assets/post_resources/math//d6328eaebbcd5c358f426dbea4bdbf70.svg?invert_in_darkmode" align=middle width=15.13700594999999pt height=22.465723500000017pt/>,<img src="assets/post_resources/math//2ec6e630f199f589a2402fdf3e0289d5.svg?invert_in_darkmode" align=middle width=8.270567249999992pt height=14.15524440000002pt/> | K=3, p=0.8 | K=3, p=0.99 | K=5, p=0.8 | K=5, p=0.99 | K=10, p=0.8 | K=10, p=0.99 |
|---------------|------------|-------------|------------|-------------|-------------|--------------|
|       0.1     |      2     |      4      |      2     |      6      |      4      |      11      |
|       0.2     |      3     |      7      |      5     |      12     |      15     |      41      |
|       0.3     |      4     |      11     |      9     |      26     |      57     |      161     |
|       0.4     |      7     |      19     |     20     |      57     |     266     |      760     |

Tablodan görüldüğü üzere gerekli iterasyon/örnekleme sayısı istenilen başarı oranına bağlı olarak hızla artmaktadır. Ancak, <img src="assets/post_resources/math//4485568012854cb7ff9d8f6f6bcff06d.svg?invert_in_darkmode" align=middle width=53.49304949999999pt height=22.465723500000017pt/> olarak seçilen bir problemde <img src="assets/post_resources/math//96382349af364ffcb6e047f689a1f0ea.svg?invert_in_darkmode" align=middle width=50.85036164999999pt height=21.18721440000001pt/> aykırı veri oranında dahi yöntem ortalama 760 iterasyon sonucunda <img src="assets/post_resources/math//dc53c54c4be602b1f785862af5db1e5a.svg?invert_in_darkmode" align=middle width=30.137091599999987pt height=24.65753399999998pt/> olasılıkla doğru bir sonuç üretmesi beklenmektedir.

Yazıda yer alan analizlerin yapıldığı kod parçaları, görseller ve kullanılan veri setlerine [ransac_algorithm](https://github.com/cescript/ransac_algorithm) GitHub sayfası üzerinden erişebilirsiniz.

**Referanslar**
* Fischler, Martin A., and Robert C. Bolles. "Random sample consensus: a paradigm for model fitting with applications to image analysis and automated cartography." Communications of the ACM 24.6 (1981): 381-395.

[RESOURCES]: # (List of the resources used by the blog post)
[linefit_example_n0]: /assets/post_resources/ransac_algorithm/linefit_example_n0.svg
[linefit_example_n1]: /assets/post_resources/ransac_algorithm/linefit_example_n1.svg
[linefit_example_n2]: /assets/post_resources/ransac_algorithm/linefit_example_n2.svg
[linefit_example_n3]: /assets/post_resources/ransac_algorithm/linefit_example_n3.svg
[ransac_example_41]: /assets/post_resources/ransac_algorithm/ransac_example_41.svg
[ransac_example_42]: /assets/post_resources/ransac_algorithm/ransac_example_42.svg
[ransac_example_43]: /assets/post_resources/ransac_algorithm/ransac_example_43.svg
[ransac_example_44]: /assets/post_resources/ransac_algorithm/ransac_example_44.svg