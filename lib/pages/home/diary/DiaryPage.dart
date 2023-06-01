import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:so_hoa_vung_trong/components/TimeLine.dart';
import 'package:so_hoa_vung_trong/components/TimeLineTop.dart';
import 'package:so_hoa_vung_trong/controllers/diary/diary_details_controller.dart';
import 'package:so_hoa_vung_trong/utils/colors.dart';
import 'package:so_hoa_vung_trong/utils/utils.dart';

class DiaryPage extends ConsumerStatefulWidget {
  final String id;
  const DiaryPage({required this.id, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiaryStatePage();
}

class _DiaryStatePage extends ConsumerState<DiaryPage> {

  @override
  Widget build(BuildContext context) {
    final diaryData = ref.watch(diaryDetailsControllerProvider(widget.id));
    final diaryLog = ref.watch(diaryLogProvider(widget.id));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhật ký sản xuất"),
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(CupertinoIcons.back),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/diary/${widget.id}/edit'), 
            icon: const Icon(CupertinoIcons.pencil_ellipsis_rectangle)
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.watch(diaryDetailsControllerProvider(widget.id).notifier).loadData();
          ref.invalidate(diaryLogProvider(widget.id));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (diaryData.loading) {
              return const Center(child: CircularProgressIndicator(),);
            }
      
            if (diaryData.data == null) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: const Center(child: Text("Không có dữ liệu nhật ký"),)
                )
              );
            }

            final diary = diaryData.data!;
      
            return Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  // color: Colors.white,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage("assets/img/diary.png"),
                                      fit: BoxFit.contain
                                    )
                                  ),
                                ),
                              ),
                              Text(diary.TenNhatKy ?? "Tên nhật ký", style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                // color: primary
                              ),),
                              const SizedBox(height: 5,),
                              Text(diary.Nam ?? "", style: const TextStyle(
                                color: second
                              ),),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)
                          ),
                          child: Builder(
                            builder: (context) {
                              final list = <Map>[
                                { "icon": CupertinoIcons.square_arrow_right, "label": 'Ngày bắt đầu', "value": formatTimeToString2(diary.NgayBatDau)},
                                { "icon": CupertinoIcons.square_arrow_left, "label": 'Ngày kết thúc', "value": formatTimeToString2(diary.NgayKetThuc)},
                                { "icon": CupertinoIcons.chart_bar_square, "label": 'Diện tích', "value": "${diary.DatCoSo} m²"},
                                { "icon": CupertinoIcons.square_grid_2x2, "label": 'Sản lượng', "value": diary.getSanLuong()}
                              ];
                              return AlignedGridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                itemCount: list.length,
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 20,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    child: Row(
                                      children: [
                                        Icon(list[index]['icon'], size: 30, color: primary,),
                                        const SizedBox(width: 10,),
                                        Expanded(child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(list[index]['label'], style: const TextStyle(fontWeight: FontWeight.w500),),
                                            Text(list[index]['value'])
                                          ],
                                        ),)
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          ),
                        ),
      
                        const SizedBox(height: 10,),
                        
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Column(
                            children: [
                              const Text("Chi tiết nhật ký sản xuất", style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500
                              ),),
                              const SizedBox(height: 10,),
                              // const Divider(height: 1, color: Colors.grey,),
                              // const SizedBox(height: 10,),

                              diaryLog.when(
                                skipLoadingOnRefresh: false,
                                data: (data) {
                                  if (data.isEmpty) {
                                    return const Text("Không có chi tiết nhật ký nào");
                                  }

                                  return TimeLineTop(
                                    indicators: data.map((e) => 
                                      Text(e.dateToString(), style: const TextStyle(color: primary, fontWeight: FontWeight.w500),),
                                    ).toList(),
                                    children: data.map((e) => 
                                      Container(
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(4),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.3),
                                              blurRadius: 2,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 2), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Tổng giờ làm: ${e.TongGioLamViec ?? '0'}", style: const TextStyle(
                                                      // fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.pink
                                                    ),),
                                                    const SizedBox(height: 5,),
                                                    Text(e.GhiChu ?? "Không có ghi chú")
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              color: second,
                                              child: const Center(
                                                child: Icon(Icons.edit, color: Colors.white,),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ).toList(),
                                  );
                                },
                                loading: () => const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: CircularProgressIndicator(),),
                                ),
                                error: (_, __) => const Text("Không thể tải chi tiết nhật ký"),
                              )
                            ],
                          ),
                        ),
                        Container(height: 65)
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  left: 12,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text("Thêm mới chi tiết"),
                  ),
                )
              ],
            );
          }
        ),
      ),
    );
  }
}