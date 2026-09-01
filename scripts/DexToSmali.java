import com.android.tools.smali.baksmali.Baksmali;
import com.android.tools.smali.baksmali.BaksmaliOptions;
import com.android.tools.smali.dexlib2.Opcodes;
import com.android.tools.smali.dexlib2.dexbacked.DexBackedDexFile;
import com.android.tools.smali.dexlib2.iface.MultiDexContainer;
import com.android.tools.smali.dexlib2.DexFileFactory;

import java.io.File;

public final class DexToSmali {
    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            throw new IllegalArgumentException("usage: DexToSmali classes.dex output-directory");
        }
        MultiDexContainer container =
                DexFileFactory.loadDexContainer(new File(args[0]), new Opcodes(34, 0));
        if (container.getDexEntryNames().isEmpty()) {
            throw new IllegalArgumentException("classes.dex is not a backed DEX entry");
        }
        String entryName = (String) container.getDexEntryNames().get(0);
        DexBackedDexFile dexFile = container.getEntry(entryName).getDexFile();
        BaksmaliOptions options = new BaksmaliOptions();
        options.debugInfo = false;
        options.localsDirective = true;
        Baksmali.disassembleDexFile(
                dexFile, new File(args[1]), 1, options);
    }
}
