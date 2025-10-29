/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/stats-02.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Stats02({ alt, ...rest }: Props) {
  return (
    <img src={String(src)} alt={alt ?? 'Stats 02'} loading="lazy" decoding="async" {...rest} />
  );
}
